---
name: read-excel
description: >
  Use when you need to read an Excel file (`.xlsx`, `.xls`) and get its contents
  as structured data. Fires on «прочитай excel» / "read the excel", «сними данные
  из xlsx» / "extract from xlsx", «парсни excel» / "parse excel file", converting
  a `.xlsx`/`.xls` to TSV or JSON for downstream processing. Utility skill used by
  workflow skills (recalculation, terminations, etc.).
version: 0.1.0
category: capability
languages:
  - en
  - ru
---

# read-excel — convert Excel files to machine-readable format

Reads `.xlsx` or `.xls` files via Python (`pandas` + `openpyxl`/`xlrd`) and outputs
as TSV or JSON.

## Input

An absolute file path to an Excel file (`.xlsx` or `.xls`).

## Procedure

1. **Check dependencies**: Ensure `pandas` is available:
   ```bash
   python -c "import pandas"
   ```
   If not installed, install:
   ```bash
   pip install pandas openpyxl xlrd
   ```

2. **Convert the file**:
   - **To TSV** (default, for tabular data):
     ```bash
     python -c "import pandas as pd; df=pd.read_excel('<path>'); df.to_csv('<output>.tsv', sep='\t', index=False)"
     ```
   - **To JSON** (for record-oriented processing):
     ```bash
     python -c "import pandas as pd; df=pd.read_excel('<path>'); print(df.to_json(orient='records', force_ascii=False, date_format='iso'))"
     ```

3. **Multi-sheet files**: If the Excel has multiple sheets, list sheet names first:
   ```bash
   python -c "import pandas as pd; xl=pd.ExcelFile('<path>'); print('\n'.join(xl.sheet_names))"
   ```
   Then ask the user which sheet to read, or read all into separate files.

4. **Read the output**: Use the `Read` tool on the generated TSV, or capture the
   JSON output directly.

## Format notes

| Format | Use case                          |
|--------|-----------------------------------|
| TSV    | Further parsing by other skills   |
| JSON   | Direct inspection, body building  |

## Triggers / non-triggers

- ✅ "прочитай file.xlsx", "parse this Excel", "сними данные из вложения .xls".
- ❌ "сделай перерасчет" → `recalculation`; "сделай прекращения" → `terminations`
  (these skills will call this one internally for Excel attachments).

## Output

Path to the generated TSV/JSON file, row count, and column names.
