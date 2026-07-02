import json
import pathlib

notebook_path = pathlib.Path("day26_mcp_a2a_lab.ipynb")
data = json.loads(notebook_path.read_text(encoding="utf-8"))

target_code = [
    "# 📝 SINH VIÊN ĐIỀN KẾT QUẢ ADK WEB — thay thế placeholder bằng quan sát thực tế\n",
    "\n",
    "adk_web_results = [\n",
    "    {\n",
    "        \"prompt_id\": \"W1\",\n",
    "        \"agents_involved\": [\"orchestrator\", \"search_agent\"],\n",
    "        \"tools_or_protocol\": \"A2A\",\n",
    "        \"outcome\": \"ĐẠT\",\n",
    "        \"notes\": \"Chuyển tiếp yêu cầu thành công sang search_agent và nhận được kết quả giải thích về Multi-agent Orchestration.\",\n",
    "    },\n",
    "    {\n",
    "        \"prompt_id\": \"W2\",\n",
    "        \"agents_involved\": [\"orchestrator\"],\n",
    "        \"tools_or_protocol\": \"MCP (search_documents, sql_query)\",\n",
    "        \"outcome\": \"ĐẠT\",\n",
    "        \"notes\": \"Gọi thành công các tool search_documents và sql_query để thu thập tài liệu và chỉ số metrics.\",\n",
    "    },\n",
    "    {\n",
    "        \"prompt_id\": \"W3\",\n",
    "        \"agents_involved\": [\"orchestrator\", \"synthesis_agent\"],\n",
    "        \"tools_or_protocol\": \"A2A → synthesis_agent\",\n",
    "        \"outcome\": \"ĐẠT\",\n",
    "        \"notes\": \"Chuyển tiếp thành công sang synthesis_agent để tổng hợp báo cáo executive report.\",\n",
    "    },\n",
    "    {\n",
    "        \"prompt_id\": \"W4\",\n",
    "        \"agents_involved\": [\"orchestrator\"],\n",
    "        \"tools_or_protocol\": \"suggest_routing\",\n",
    "        \"outcome\": \"ĐẠT\",\n",
    "        \"notes\": \"recommended_agent = database_agent\",\n",
    "    },\n",
    "    {\n",
    "        \"prompt_id\": \"W5\",\n",
    "        \"agents_involved\": [\"orchestrator\"],\n",
    "        \"tools_or_protocol\": \"MCP sql_query — governance deny\",\n",
    "        \"outcome\": \"ĐẠT\",\n",
    "        \"notes\": \"Yêu cầu DROP TABLE bị chặn hoàn toàn bởi GovernanceGuard vì không phải câu lệnh SELECT.\",\n",
    "    },\n",
    "]\n"
]

for cell in data.get("cells", []):
    if cell.get("cell_type") == "code" and any("adk_web_results = [" in line for line in cell.get("source", [])):
        source_lines = cell["source"]
        for idx, line in enumerate(source_lines):
            if "print(f" in line:
                print_part = source_lines[idx:]
                break
        else:
            print_part = []
        cell["source"] = target_code + ["\n"] + print_part
        print("Successfully updated notebook cell!")
        break

notebook_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
