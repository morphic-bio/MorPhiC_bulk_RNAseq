import os
import pandas as pd
from PIL import Image
import csv

EXCEL_FILE = os.path.join("meta_data_web_portal", "JAX_bulk_RNAseq_release2.xlsx")
OUTPUT_REPORT = "validation_report.csv"

REPO_ROOT = os.getcwd()


def clean_path(path):
    #"""Remove leading 'MorPhiC_bulk_RNAseq/' if present and join with repo root"""
    if path.startswith("MorPhiC_bulk_RNAseq/"):
        path = path.replace("MorPhiC_bulk_RNAseq/", "", 1)
    return os.path.join(REPO_ROOT, path)


def validate_png(file_path):
    try:
        with Image.open(file_path) as img:
            img.verify()  # corruption check
        with Image.open(file_path) as img:  # reopen for properties
            width, height = img.size
            mode = img.mode
            if width != 1920:
                return False, f"Invalid width: {width}, expected 1920"
            if mode not in ["RGB", "RGBA"]:
                return False, f"Invalid mode: {mode}, expected RGB or RGBA"
            if mode == "RGB":
                return False, "Transparency missing (should be RGBA)"
        return True, "OK"
    except Exception as e:
        return False, str(e)


def validate_tsv(file_path):
    try:
        pd.read_csv(file_path, sep="\t", nrows=5)
        return True, "OK"
    except Exception as e:
        return False, str(e)


def main():
    df = pd.read_excel(EXCEL_FILE)

    results = []

    for _, row in df.iterrows():
        matrix_name = str(row.get("DAV Matrix Name", ""))
        matrix_loc = str(row.get("DAV Matrix Location", ""))
        image_name = str(row.get("Output Image Object", ""))
        image_loc = str(row.get("Output Image Location", ""))

        # Skip .rds files
        if matrix_name.endswith(".rds"):
            continue

        # TSV validation
        if matrix_name.endswith(".tsv"):
            file_path = os.path.join(clean_path(matrix_loc), matrix_name)
            if os.path.exists(file_path):
                status, message = validate_tsv(file_path)
            else:
                status, message = False, "File not found"
            results.append([matrix_name, "TSV", "OK" if status else "FAILED", message])

        # PNG validation
        if image_name.endswith(".png"):
            file_path = os.path.join(clean_path(image_loc), image_name)
            if os.path.exists(file_path):
                status, message = validate_png(file_path)
            else:
                status, message = False, "File not found"
            results.append([image_name, "PNG", "OK" if status else "FAILED", message])

    # Save report
    with open(OUTPUT_REPORT, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["File Name", "File Type", "Validation Status", "Message"])
        writer.writerows(results)

    print(f"✅ Validation completed. Report saved to {OUTPUT_REPORT}")


if __name__ == "__main__":
    main()
