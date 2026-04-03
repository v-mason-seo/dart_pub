# [경로: widgets/ocr_page.py]

from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton,
    QFileDialog, QTextEdit, QGroupBox, QCheckBox, QSlider,
    QSpinBox, QComboBox, QScrollArea, QSplitter, QDoubleSpinBox
)
from PySide6.QtCore import Qt
from PySide6.QtGui import QPixmap, QImage
import cv2
import numpy as np
from PIL import Image
import easyocr

from constants import CLR_BG, CLR_TEXT, CLR_SUBTEXT, CLR_CARD, CLR_DIVIDER, CLR_ACCENT, CLR_SIDEBAR


# EasyOCR Reader 초기화 (앱 시작 시 1회만)
_reader_cache = {}

def get_reader(langs: list, gpu: bool) -> easyocr.Reader:
    key = (tuple(sorted(langs)), gpu)
    if key not in _reader_cache:
        _reader_cache[key] = easyocr.Reader(langs, gpu=gpu, download_enabled=False)
    return _reader_cache[key]


def ndarray_to_qpixmap(img: np.ndarray) -> QPixmap:
    """OpenCV ndarray → QPixmap 변환"""
    if len(img.shape) == 2:
        h, w = img.shape
        qimg = QImage(img.data, w, h, w, QImage.Format_Grayscale8)
    else:
        h, w, ch = img.shape
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        qimg = QImage(rgb.data, w, h, w * ch, QImage.Format_RGB888)
    return QPixmap.fromImage(qimg)


class ImageViewer(QLabel):
    """이미지를 비율 유지하며 표시하는 라벨"""
    def __init__(self, placeholder: str, parent=None):
        super().__init__(placeholder, parent)
        self.setAlignment(Qt.AlignCenter)
        self.setMinimumSize(380, 420)
        self.setStyleSheet(f"""
            QLabel {{
                background: {CLR_CARD};
                color: {CLR_SUBTEXT};
                border: 2px dashed {CLR_DIVIDER};
                border-radius: 8px;
                font-size: 13px;
            }}
        """)
        self._pixmap_orig = None

    def set_image_ndarray(self, img: np.ndarray):
        self._pixmap_orig = ndarray_to_qpixmap(img)
        self._update_display()

    def set_image_path(self, path: str):
        self._pixmap_orig = QPixmap(path)
        self._update_display()

    def _update_display(self):
        if self._pixmap_orig:
            scaled = self._pixmap_orig.scaled(
                self.width() - 8, self.height() - 8,
                Qt.KeepAspectRatio, Qt.SmoothTransformation
            )
            self.setPixmap(scaled)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self._update_display()


class OCRPage(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setStyleSheet(f"background: {CLR_BG};")
        self._image_path = None
        self._original_img = None  # np.ndarray

        # 메인 레이아웃
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(16, 16, 16, 16)
        main_layout.setSpacing(12)

        # ── 상단: 제목 + 파일 열기 버튼 ──
        top_row = QHBoxLayout()
        title = QLabel("글자인식 (OCR)")
        title.setStyleSheet(f"color: {CLR_TEXT}; font-size: 16px; font-weight: bold;")
        top_row.addWidget(title)
        top_row.addStretch()

        self.btn_open = QPushButton("🖼️  이미지 열기")
        self._style_btn_primary(self.btn_open)
        self.btn_open.clicked.connect(self._open_image)
        top_row.addWidget(self.btn_open)

        self.btn_run = QPushButton("🔍  텍스트 추출")
        self._style_btn_primary(self.btn_run)
        self.btn_run.setEnabled(False)
        self.btn_run.clicked.connect(self._run_ocr)
        top_row.addWidget(self.btn_run)

        main_layout.addLayout(top_row)

        # ── 중간: 이미지 + 옵션 패널 ──
        middle_splitter = QSplitter(Qt.Horizontal)
        middle_splitter.setStyleSheet("QSplitter::handle { background: transparent; }")

        # 좌측: 원본 + 전처리 이미지
        image_widget = QWidget()
        image_layout = QHBoxLayout(image_widget)
        image_layout.setContentsMargins(0, 0, 0, 0)
        image_layout.setSpacing(8)

        orig_box = QVBoxLayout()
        orig_lbl = QLabel("원본 이미지")
        orig_lbl.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")
        orig_lbl.setAlignment(Qt.AlignCenter)
        self.viewer_orig = ImageViewer("이미지를 선택하세요")
        orig_box.addWidget(orig_lbl)
        orig_box.addWidget(self.viewer_orig)

        proc_box = QVBoxLayout()
        proc_lbl = QLabel("전처리 결과")
        proc_lbl.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")
        proc_lbl.setAlignment(Qt.AlignCenter)
        self.viewer_proc = ImageViewer("전처리 후 표시됩니다")
        proc_box.addWidget(proc_lbl)
        proc_box.addWidget(self.viewer_proc)

        image_layout.addLayout(orig_box, 1)
        image_layout.addLayout(proc_box, 1)

        middle_splitter.addWidget(image_widget)

        # 우측: 옵션 패널 (스크롤)
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFixedWidth(260)
        scroll.setStyleSheet(f"QScrollArea {{ border: none; background: {CLR_BG}; }}")

        option_container = QWidget()
        option_container.setStyleSheet(f"background: {CLR_BG};")
        option_layout = QVBoxLayout(option_container)
        option_layout.setContentsMargins(4, 0, 4, 0)
        option_layout.setSpacing(10)
        option_layout.setAlignment(Qt.AlignTop)

        # ── 전처리 옵션 그룹 ──
        pre_group = self._make_group("전처리 옵션")
        pre_layout = QVBoxLayout(pre_group)
        pre_layout.setSpacing(8)

        # 전처리 ON/OFF
        self.chk_preprocess = QCheckBox("전처리 사용")
        self.chk_preprocess.setChecked(True)
        self.chk_preprocess.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        self.chk_preprocess.toggled.connect(self._on_preprocess_toggle)
        pre_layout.addWidget(self.chk_preprocess)

        # 업스케일
        self.chk_upscale = QCheckBox("업스케일 (해상도 향상)")
        self.chk_upscale.setChecked(True)
        self.chk_upscale.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        pre_layout.addWidget(self.chk_upscale)

        scale_row = QHBoxLayout()
        scale_lbl = QLabel("  배율:")
        scale_lbl.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")
        self.spin_scale = QSpinBox()
        self.spin_scale.setRange(1, 4)
        self.spin_scale.setValue(2)
        self.spin_scale.setFixedWidth(60)
        self._style_spinbox(self.spin_scale)
        scale_row.addWidget(scale_lbl)
        scale_row.addWidget(self.spin_scale)
        scale_row.addStretch()
        pre_layout.addLayout(scale_row)

        # 자동 반전
        self.chk_invert = QCheckBox("자동 반전 (어두운 배경)")
        self.chk_invert.setChecked(True)
        self.chk_invert.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        pre_layout.addWidget(self.chk_invert)

        # 노이즈 제거
        self.chk_denoise = QCheckBox("노이즈 제거")
        self.chk_denoise.setChecked(True)
        self.chk_denoise.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        pre_layout.addWidget(self.chk_denoise)

        denoise_row = QHBoxLayout()
        denoise_lbl = QLabel("  강도:")
        denoise_lbl.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")
        self.spin_denoise = QSpinBox()
        self.spin_denoise.setRange(1, 30)
        self.spin_denoise.setValue(10)
        self.spin_denoise.setFixedWidth(60)
        self._style_spinbox(self.spin_denoise)
        denoise_row.addWidget(denoise_lbl)
        denoise_row.addWidget(self.spin_denoise)
        denoise_row.addStretch()
        pre_layout.addLayout(denoise_row)

        # CLAHE 대비 강화
        self.chk_clahe = QCheckBox("CLAHE 대비 강화")
        self.chk_clahe.setChecked(True)
        self.chk_clahe.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        pre_layout.addWidget(self.chk_clahe)

        clahe_row = QHBoxLayout()
        clahe_lbl = QLabel("  클립:")
        clahe_lbl.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")
        self.spin_clahe = QDoubleSpinBox()
        self.spin_clahe.setRange(0.5, 10.0)
        self.spin_clahe.setSingleStep(0.5)
        self.spin_clahe.setValue(2.0)
        self.spin_clahe.setFixedWidth(70)
        self._style_spinbox(self.spin_clahe)
        clahe_row.addWidget(clahe_lbl)
        clahe_row.addWidget(self.spin_clahe)
        clahe_row.addStretch()
        pre_layout.addLayout(clahe_row)

        # 샤프닝
        self.chk_sharpen = QCheckBox("샤프닝 (엣지 강화)")
        self.chk_sharpen.setChecked(False)
        self.chk_sharpen.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        pre_layout.addWidget(self.chk_sharpen)

        # 전처리 미리보기 버튼
        self.btn_preview = QPushButton("전처리 미리보기")
        self.btn_preview.setFixedHeight(32)
        self.btn_preview.setEnabled(False)
        self.btn_preview.setCursor(Qt.PointingHandCursor)
        self.btn_preview.setStyleSheet(f"""
            QPushButton {{
                background: {CLR_CARD};
                color: {CLR_SUBTEXT};
                border: 1px solid {CLR_DIVIDER};
                border-radius: 6px;
                font-size: 12px;
            }}
            QPushButton:enabled {{
                color: {CLR_TEXT};
                border-color: {CLR_ACCENT};
            }}
            QPushButton:enabled:hover {{ background: {CLR_SIDEBAR}; }}
        """)
        self.btn_preview.clicked.connect(self._update_preview)
        pre_layout.addWidget(self.btn_preview)

        option_layout.addWidget(pre_group)

        # ── EasyOCR 옵션 그룹 ──
        ocr_group = self._make_group("EasyOCR 옵션")
        ocr_layout = QVBoxLayout(ocr_group)
        ocr_layout.setSpacing(8)

        # 언어 선택
        lang_lbl = QLabel("인식 언어:")
        lang_lbl.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        ocr_layout.addWidget(lang_lbl)

        self.chk_korean = QCheckBox("한국어 (ko)")
        self.chk_korean.setChecked(True)
        self.chk_korean.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        ocr_layout.addWidget(self.chk_korean)

        self.chk_english = QCheckBox("영어 (en)")
        self.chk_english.setChecked(True)
        self.chk_english.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        ocr_layout.addWidget(self.chk_english)

        # GPU
        self.chk_gpu = QCheckBox("GPU 사용 (없으면 자동 CPU)")
        self.chk_gpu.setChecked(False)
        self.chk_gpu.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        ocr_layout.addWidget(self.chk_gpu)

        # 최소 신뢰도
        conf_lbl = QLabel("최소 신뢰도 (낮을수록 더 많이 인식):")
        conf_lbl.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        conf_lbl.setWordWrap(True)
        ocr_layout.addWidget(conf_lbl)

        conf_row = QHBoxLayout()
        self.sld_conf = QSlider(Qt.Horizontal)
        self.sld_conf.setRange(0, 100)
        self.sld_conf.setValue(30)
        self.sld_conf.setStyleSheet(f"QSlider::groove:horizontal {{ background: {CLR_DIVIDER}; height: 4px; border-radius: 2px; }} QSlider::sub-page:horizontal {{ background: {CLR_ACCENT}; height: 4px; border-radius: 2px; }} QSlider::handle:horizontal {{ background: {CLR_ACCENT}; width: 14px; height: 14px; margin: -5px 0; border-radius: 7px; }}")
        self.lbl_conf = QLabel("0.30")
        self.lbl_conf.setFixedWidth(36)
        self.lbl_conf.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")
        self.sld_conf.valueChanged.connect(
            lambda v: self.lbl_conf.setText(f"{v/100:.2f}")
        )
        conf_row.addWidget(self.sld_conf)
        conf_row.addWidget(self.lbl_conf)
        ocr_layout.addLayout(conf_row)

        # 텍스트 임계값
        text_thr_lbl = QLabel("텍스트 감지 임계값:")
        text_thr_lbl.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        ocr_layout.addWidget(text_thr_lbl)

        thr_row = QHBoxLayout()
        self.sld_text_thr = QSlider(Qt.Horizontal)
        self.sld_text_thr.setRange(1, 99)
        self.sld_text_thr.setValue(70)
        self.sld_text_thr.setStyleSheet(self.sld_conf.styleSheet())
        self.lbl_text_thr = QLabel("0.70")
        self.lbl_text_thr.setFixedWidth(36)
        self.lbl_text_thr.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")
        self.sld_text_thr.valueChanged.connect(
            lambda v: self.lbl_text_thr.setText(f"{v/100:.2f}")
        )
        thr_row.addWidget(self.sld_text_thr)
        thr_row.addWidget(self.lbl_text_thr)
        ocr_layout.addLayout(thr_row)

        # 단락 합치기
        self.chk_paragraph = QCheckBox("단락 자동 합치기")
        self.chk_paragraph.setChecked(False)
        self.chk_paragraph.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        ocr_layout.addWidget(self.chk_paragraph)

        # 텍스트 방향
        dir_lbl = QLabel("텍스트 방향:")
        dir_lbl.setStyleSheet(f"color: {CLR_TEXT}; font-size: 12px;")
        ocr_layout.addWidget(dir_lbl)

        self.combo_dir = QComboBox()
        self.combo_dir.addItems(["가로 + 세로", "가로만", "세로만"])
        self.combo_dir.setFixedHeight(30)
        self.combo_dir.setStyleSheet(f"""
            QComboBox {{
                background: {CLR_CARD};
                color: {CLR_TEXT};
                border: 1px solid {CLR_DIVIDER};
                border-radius: 4px;
                padding: 0 8px;
                font-size: 12px;
            }}
            QComboBox::drop-down {{ border: none; width: 20px; }}
            QComboBox QAbstractItemView {{
                background: {CLR_CARD};
                color: {CLR_TEXT};
                selection-background-color: {CLR_ACCENT};
                border: 1px solid {CLR_DIVIDER};
            }}
        """)
        ocr_layout.addWidget(self.combo_dir)

        option_layout.addWidget(ocr_group)
        option_layout.addStretch()

        scroll.setWidget(option_container)
        middle_splitter.addWidget(scroll)
        middle_splitter.setSizes([720, 260])

        main_layout.addWidget(middle_splitter, 1)

        # ── 하단: 결과 텍스트 ──
        result_group = self._make_group("인식 결과")
        result_layout = QVBoxLayout(result_group)
        result_layout.setSpacing(6)

        self.text_result = QTextEdit()
        self.text_result.setFixedHeight(130)
        self.text_result.setPlaceholderText("텍스트 추출 결과가 여기에 표시됩니다...")
        self.text_result.setStyleSheet(f"""
            QTextEdit {{
                background: {CLR_CARD};
                color: {CLR_TEXT};
                border: 1px solid {CLR_DIVIDER};
                border-radius: 6px;
                padding: 8px;
                font-size: 13px;
                font-family: "Consolas", "Malgun Gothic", monospace;
            }}
        """)
        result_layout.addWidget(self.text_result)

        btn_row2 = QHBoxLayout()
        self.btn_copy = QPushButton("📋  복사")
        self._style_btn_secondary(self.btn_copy)
        self.btn_copy.clicked.connect(self._copy_result)

        self.btn_clear = QPushButton("🗑️  지우기")
        self._style_btn_secondary(self.btn_clear)
        self.btn_clear.clicked.connect(self.text_result.clear)

        self.lbl_status = QLabel("")
        self.lbl_status.setStyleSheet(f"color: {CLR_SUBTEXT}; font-size: 11px;")

        btn_row2.addWidget(self.btn_copy)
        btn_row2.addWidget(self.btn_clear)
        btn_row2.addStretch()
        btn_row2.addWidget(self.lbl_status)
        result_layout.addLayout(btn_row2)

        main_layout.addWidget(result_group)

    # ── 스타일 헬퍼 ──

    def _make_group(self, title: str) -> QGroupBox:
        g = QGroupBox(title)
        g.setStyleSheet(f"""
            QGroupBox {{
                color: {CLR_TEXT};
                font-size: 12px;
                font-weight: bold;
                border: 1px solid {CLR_DIVIDER};
                border-radius: 6px;
                margin-top: 8px;
                padding-top: 4px;
                background: {CLR_CARD};
            }}
            QGroupBox::title {{
                subcontrol-origin: margin;
                left: 10px;
                padding: 0 4px;
            }}
        """)
        return g

    def _style_btn_primary(self, btn: QPushButton):
        btn.setFixedHeight(34)
        btn.setCursor(Qt.PointingHandCursor)
        btn.setStyleSheet(f"""
            QPushButton {{
                background: {CLR_ACCENT};
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 13px;
                padding: 0 16px;
            }}
            QPushButton:hover {{ background: #3949AB; }}
            QPushButton:disabled {{
                background: {CLR_DIVIDER};
                color: {CLR_SUBTEXT};
            }}
        """)

    def _style_btn_secondary(self, btn: QPushButton):
        btn.setFixedHeight(30)
        btn.setCursor(Qt.PointingHandCursor)
        btn.setStyleSheet(f"""
            QPushButton {{
                background: {CLR_CARD};
                color: {CLR_TEXT};
                border: 1px solid {CLR_DIVIDER};
                border-radius: 6px;
                font-size: 12px;
                padding: 0 14px;
            }}
            QPushButton:hover {{ background: {CLR_SIDEBAR}; }}
        """)

    def _style_spinbox(self, sb):
        sb.setStyleSheet(f"""
            QSpinBox, QDoubleSpinBox {{
                background: {CLR_CARD};
                color: {CLR_TEXT};
                border: 1px solid {CLR_DIVIDER};
                border-radius: 4px;
                padding: 2px 4px;
                font-size: 12px;
            }}
        """)

    # ── 전처리 ON/OFF 토글 ──

    def _on_preprocess_toggle(self, checked: bool):
        for w in [self.chk_upscale, self.spin_scale,
                  self.chk_invert, self.chk_denoise, self.spin_denoise,
                  self.chk_clahe, self.spin_clahe, self.chk_sharpen,
                  self.btn_preview]:
            w.setEnabled(checked)

    # ── 이미지 열기 ──

    def _open_image(self):
        path, _ = QFileDialog.getOpenFileName(
            self, "이미지 파일 선택", "",
            "이미지 파일 (*.png *.jpg *.jpeg *.bmp *.tiff *.tif)"
        )
        if not path:
            return
        self._image_path = path
        self._original_img = cv2.imread(path)
        self.viewer_orig.set_image_path(path)
        self.viewer_proc.setText("전처리 후 표시됩니다")
        self.viewer_proc._pixmap_orig = None
        self.btn_run.setEnabled(True)
        self.btn_preview.setEnabled(True)
        self.lbl_status.setText("")

    # ── 전처리 ──

    def _preprocess(self, img: np.ndarray) -> np.ndarray:
        if not self.chk_preprocess.isChecked():
            return img

        result = img.copy()

        # 1) 업스케일
        if self.chk_upscale.isChecked():
            scale = self.spin_scale.value()
            h, w = result.shape[:2]
            result = cv2.resize(result, (w * scale, h * scale),
                                interpolation=cv2.INTER_CUBIC)

        # 2) 그레이스케일
        gray = cv2.cvtColor(result, cv2.COLOR_BGR2GRAY)

        # 3) 자동 반전
        if self.chk_invert.isChecked():
            if np.mean(gray) < 127:
                gray = cv2.bitwise_not(gray)

        # 4) 노이즈 제거
        if self.chk_denoise.isChecked():
            h_val = self.spin_denoise.value()
            gray = cv2.fastNlMeansDenoising(gray, h=h_val)

        # 5) CLAHE 대비 강화
        if self.chk_clahe.isChecked():
            clip = self.spin_clahe.value()
            clahe = cv2.createCLAHE(clipLimit=clip, tileGridSize=(8, 8))
            gray = clahe.apply(gray)

        # 6) 샤프닝
        if self.chk_sharpen.isChecked():
            kernel = np.array([[0, -1, 0], [-1, 5, -1], [0, -1, 0]])
            gray = cv2.filter2D(gray, -1, kernel)

        # EasyOCR은 컬러 또는 그레이 ndarray 모두 허용 → 그레이 반환
        return gray

    def _update_preview(self):
        if self._original_img is None:
            return
        processed = self._preprocess(self._original_img)
        self.viewer_proc.set_image_ndarray(processed)

    # ── OCR 실행 ──

    def _run_ocr(self):
        if self._original_img is None:
            return

        self.lbl_status.setText("인식 중...")
        self.btn_run.setEnabled(False)
        self.repaint()

        try:
            # 전처리
            processed = self._preprocess(self._original_img)
            self.viewer_proc.set_image_ndarray(processed)

            # 언어 설정
            langs = []
            if self.chk_korean.isChecked():
                langs.append('ko')
            if self.chk_english.isChecked():
                langs.append('en')
            if not langs:
                langs = ['en']

            # EasyOCR 옵션
            gpu = self.chk_gpu.isChecked()
            min_conf = self.sld_conf.value() / 100
            text_thr = self.sld_text_thr.value() / 100
            paragraph = self.chk_paragraph.isChecked()

            dir_idx = self.combo_dir.currentIndex()
            rotation_info = None
            if dir_idx == 1:
                rotation_info = [0]       # 가로만
            elif dir_idx == 2:
                rotation_info = [90, 270] # 세로만

            reader = get_reader(langs, gpu)

            kwargs = dict(
                detail=1,
                paragraph=paragraph,
                text_threshold=text_thr,
            )
            if rotation_info is not None:
                kwargs['rotation_info'] = rotation_info

            results = reader.readtext(processed, **kwargs)

            # 신뢰도 필터 후 텍스트 추출
            lines = [text for (_, text, conf) in results if conf >= min_conf]
            output = "\n".join(lines)

            self.text_result.setPlainText(output)
            self.lbl_status.setText(f"완료 — {len(lines)}개 텍스트 블록 인식")

        except Exception as e:
            self.lbl_status.setText(f"오류: {e}")

        finally:
            self.btn_run.setEnabled(True)

    # ── 복사 ──

    def _copy_result(self):
        from PySide6.QtWidgets import QApplication
        text = self.text_result.toPlainText()
        if text:
            QApplication.clipboard().setText(text)
            self.lbl_status.setText("클립보드에 복사됨")
