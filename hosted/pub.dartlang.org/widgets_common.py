from PySide6.QtGui import QKeySequence
from bs4 import BeautifulSoup
import re


def _parse_classes_bg(html: str) -> dict:
    """<style> 에서 클래스별 background 색상 추출 → {클래스명: 색상문자열}"""
    bg_map = {}
    style_match = re.search(r"<style[^>]*>(.*?)</style>", html, re.DOTALL | re.IGNORECASE)
    if not style_match:
        return bg_map
    style_text = style_match.group(1)
    # .xl66 { ... background:#FFFF00; ... }
    for block in re.finditer(r"\.(xl\w+)\s*\{([^}]*)\}", style_text):
        cls_name = block.group(1)
        props = block.group(2)
        bg_match = re.search(r"background\s*:\s*([^;]+)", props, re.IGNORECASE)
        if bg_match:
            color = bg_match.group(1).strip().lower()
            bg_map[cls_name] = color
    return bg_map


def _is_header_row(tr, bg_map: dict) -> bool:
    """tr 안의 td 중 하나라도 배경색이 있으면 헤더 행으로 판단"""
    NO_COLOR = {"white", "#ffffff", "none", "auto", "window", ""}
    for td in tr.find_all("td"):
        cls = td.get("class", [])
        if isinstance(cls, list):
            cls = cls[0] if cls else ""
        color = bg_map.get(cls, "")
        if color and color not in NO_COLOR:
            return True
    return False


class PasteableTable(QTableWidget):
    """Ctrl+V로 엑셀 복사 내용을 붙여넣을 수 있는 테이블"""

    def keyPressEvent(self, event):
        if event.matches(QKeySequence.Paste):
            self._paste_from_clipboard()
        else:
            super().keyPressEvent(event)

    def _paste_from_clipboard(self):
        clipboard = QApplication.clipboard()
        mime = clipboard.mimeData()

        # ── HTML 파싱 시도 ──
        if mime.hasHtml():
            parsed = self._parse_html(mime.html())
            if parsed is not None:
                self._write_rows(parsed)
                return

        # ── fallback: text/plain ──
        text = mime.text()
        if not text:
            return
        rows = [row.split("\t") for row in text.rstrip("\n").split("\n")]
        self._write_rows(rows)

    def _parse_html(self, html: str):
        """HTML에서 데이터 행만 추출 → [[셀값, ...], ...]"""
        bg_map = _parse_classes_bg(html)
        soup = BeautifulSoup(html, "html.parser")
        data_rows = []
        for tr in soup.find_all("tr"):
            if _is_header_row(tr, bg_map):
                print(f"[HTML] 헤더 행 스킵: {[td.get_text(strip=True) for td in tr.find_all('td')]}")
                continue
            cells = [td.get_text(strip=True) for td in tr.find_all("td")]
            if any(cells):  # 빈 행 제외
                data_rows.append(cells)
                print(f"[HTML] 데이터 행: {cells}")
        return data_rows if data_rows else None

    def _write_rows(self, rows: list):
        """파싱된 행을 테이블에 기록"""
        start_row = self.currentRow()
        start_col = self.currentColumn()
        if start_row < 0:
            start_row = 0
        if start_col < 0:
            start_col = 0

        required_row = start_row + len(rows)
        if required_row > self.rowCount():
            self.setRowCount(required_row)

        for r_offset, row_data in enumerate(rows):
            for c_offset, value in enumerate(row_data):
                target_row = start_row + r_offset
                target_col = start_col + c_offset
                if target_col < self.columnCount():
                    self.setItem(target_row, target_col, QTableWidgetItem(value))
