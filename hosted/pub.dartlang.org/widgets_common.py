# [경로: widgets/common.py]

from PySide6.QtWidgets import QTableWidget, QTableWidgetItem, QApplication
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
            result = self._parse_html(mime.html())
            if result is not None:
                header_row, data_rows = result
                self._write_rows_by_header(header_row, data_rows)
                return

        # ── fallback: text/plain ──
        text = mime.text()
        if not text:
            return
        rows = [row.split("\t") for row in text.rstrip("\n").split("\n")]
        self._write_rows(rows)

    def _parse_html(self, html: str):
        """HTML에서 헤더/데이터 행 분리 → (헤더리스트, [[셀값,...],...])"""
        bg_map = _parse_classes_bg(html)
        soup = BeautifulSoup(html, "html.parser")
        header_row = None
        data_rows = []

        def _cell_text(td) -> str:
            for br in td.find_all("br"):
                br.replace_with(" ")
            return td.get_text(strip=True)

        for tr in soup.find_all("tr"):
            cells = [_cell_text(td) for td in tr.find_all("td")]
            if not any(cells):
                continue
            if _is_header_row(tr, bg_map):
                header_row = cells  # 마지막 헤더 행을 컬럼명으로 사용
            else:
                data_rows.append(cells)

        return (header_row, data_rows) if data_rows else None

    def _write_rows(self, rows: list):
        """파싱된 행을 테이블에 순서대로 기록 (fallback용)"""
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

    def _write_rows_by_header(self, paste_headers: list, rows: list):
        """헤더명 기준으로 그리드 컬럼 위치를 찾아 데이터 기록"""

        # 그리드 헤더명 → 컬럼 인덱스 매핑
        grid_headers = {}
        for i in range(self.columnCount()):
            name = self.horizontalHeaderItem(i)
            if name:
                grid_headers[name.text().strip()] = i

        # 붙여넣기 헤더 → 그리드 컬럼 인덱스 매핑
        if paste_headers:
            col_map = []
            for h in paste_headers:
                idx = grid_headers.get(h.strip())
                col_map.append(idx)  # 매칭 안되면 None
        else:
            col_map = list(range(self.columnCount()))

        start_row = self.currentRow()
        if start_row < 0:
            start_row = 0

        required_row = start_row + len(rows)
        if required_row > self.rowCount():
            self.setRowCount(required_row)

        for r_offset, row_data in enumerate(rows):
            target_row = start_row + r_offset
            for c_offset, value in enumerate(row_data):
                if c_offset >= len(col_map):
                    break
                target_col = col_map[c_offset]
                if target_col is None:
                    continue  # 매칭 안된 컬럼 버림
                self.setItem(target_row, target_col, QTableWidgetItem(value))
