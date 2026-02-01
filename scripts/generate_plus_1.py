#!/usr/bin/env python3
"""
+1足し算プリント一括生成スクリプト
1+1 から 100+1 まで、10問ずつ10ページのPDFを生成
"""

import os
import subprocess
import tempfile
from pathlib import Path

# プロジェクトルート
PROJECT_ROOT = Path(__file__).parent.parent  # scriptsの親ディレクトリ
SHEETS_DIR = PROJECT_ROOT / "sheets" / "addition" / "plus-1"
OUTPUT_DIR = PROJECT_ROOT / "output" / "addition"

# 出力ディレクトリを作成
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def generate_sheet_file(sheet_num):
    """個別シートファイルを生成"""
    content = f"""#import "/generators/addition.typ": create-plus-one-sheet

#create-plus-one-sheet({sheet_num})
"""
    filepath = SHEETS_DIR / f"sheet-{sheet_num:02d}.typ"
    filepath.write_text(content, encoding="utf-8")
    return filepath

def compile_sheet(sheet_file, output_file):
    """Typstでコンパイル"""
    result = subprocess.run(
        ["typst", "compile", "--root", str(PROJECT_ROOT), str(sheet_file), str(output_file)],
        capture_output=True,
        text=True
    )
    if result.returncode == 0:
        print(f"✓ {output_file.name}")
    else:
        print(f"✗ {output_file.name}")
        print(f"  Error: {result.stderr}")
    return result.returncode == 0

def merge_pdfs_with_pypdf(pdf_files, output_file):
    """PyPDF2でPDFを結合"""
    try:
        from PyPDF2 import PdfMerger
        
        merger = PdfMerger()
        for pdf in pdf_files:
            merger.append(str(pdf))
        
        merger.write(str(output_file))
        merger.close()
        return True
    except ImportError:
        return False

def merge_pdfs_with_gs(pdf_files, output_file):
    """Ghostscriptでマージ"""
    cmd = ["gs", "-dBATCH", "-dNOPAUSE", "-q", "-sDEVICE=pdfwrite",
           f"-sOutputFile={output_file}"] + [str(f) for f in pdf_files]
    result = subprocess.run(cmd, capture_output=True)
    return result.returncode == 0

def main():
    total_sheets = 10
    
    print(f"=== +1足し算プリント生成 ===")
    print(f"総問題数: 100問（1+1 から 100+1）")
    print(f"ページ数: {total_sheets}ページ")
    print()
    
    # 一時ディレクトリで個別PDFを生成
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        pdf_files = []
        
        for sheet_num in range(1, total_sheets + 1):
            # シートファイル生成
            sheet_file = generate_sheet_file(sheet_num)
            
            # 一時PDF出力先
            temp_pdf = temp_path / f"sheet-{sheet_num:02d}.pdf"
            
            # コンパイル
            if compile_sheet(sheet_file, temp_pdf):
                pdf_files.append(temp_pdf)
            else:
                print("エラー: コンパイル失敗")
                return
        
        print()
        print("PDFを結合中...")
        
        # 最終出力ファイル
        output_file = OUTPUT_DIR / "plus-1-all.pdf"
        
        # PyPDF2で結合を試み、失敗したらGhostscript
        if not merge_pdfs_with_pypdf(pdf_files, output_file):
            if merge_pdfs_with_gs(pdf_files, output_file):
                print(f"✓ 完了: {output_file} ({total_sheets}ページ)")
            else:
                print("エラー: PDF結合に失敗しました")
                print("PyPDF2またはGhostscriptをインストールしてください")
                print("  pip install PyPDF2")
                print("  brew install ghostscript")
        else:
            print(f"✓ 完了: {output_file} ({total_sheets}ページ)")

if __name__ == "__main__":
    main()