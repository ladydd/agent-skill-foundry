# Report Data Contract

Use this when a skill produces an offline HTML report. `report_data.json` is the exact view model used by the renderer. It is required for HTML reports.

## Required Shape

```json
{
  "schema_version": "1.0",
  "report_id": "domain_YYYYMMDD_HHMMSS",
  "title": "报告标题",
  "generated_at": "2026-06-24T12:00:00+08:00",
  "metadata": {
    "marketplace": "US",
    "date_range": "2025-06-24 to 2026-06-24",
    "source_summary": ["input file or entity summary"]
  },
  "summary_cards": [
    {
      "id": "total_value",
      "label": "总量",
      "value": 12345,
      "unit": "件",
      "note": "样本期"
    }
  ],
  "conclusions": [
    {
      "id": "main_takeaway",
      "title": "关键结论",
      "body": "一两句业务解释",
      "confidence": "medium",
      "source_fields": ["03_analysis.total_sales"]
    }
  ],
  "charts": [
    {
      "id": "monthly_trend",
      "type": "line",
      "title": "月度趋势",
      "source_fields": ["03_analysis.monthly"],
      "units": {"y": "销售额", "x": "月份"},
      "data": [],
      "empty_state": "没有足够数据绘制该图"
    }
  ],
  "tables": [
    {
      "id": "detail_table",
      "title": "明细",
      "columns": [
        {"key": "name", "label": "名称", "align": "left"},
        {"key": "value", "label": "数值", "align": "right"}
      ],
      "rows": []
    }
  ],
  "optional_sections": [],
  "warnings": [],
  "appendix": {
    "basis_files": ["01_input_manifest.json", "03_analysis.json"],
    "calculation_notes": []
  }
}
```

## Rules

- Keep calculation results and display labels separate. Calculations belong in `03_analysis.json`; display-ready labels belong in `report_data.json`.
- Every chart must declare `id`, `type`, `title`, `source_fields`, `data`, and `empty_state`.
- Every table must declare columns and align numeric columns right.
- Warnings must describe data limitations without overriding deterministic metrics.
- Optional evidence belongs in `optional_sections`; it cannot overwrite core structured data.
- The renderer must fail if required top-level fields are missing.

## Safe HTML Injection

Preferred Go pattern:

```go
dataJSON, err := json.Marshal(reportData)
// render fixed template with html/template
// place dataJSON inside <script type="application/json" id="report-data">
```

Do not insert raw user text, product titles, or public web excerpts into JavaScript strings without JSON escaping. Do not build the whole page with ad hoc string concatenation.
