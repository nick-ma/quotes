# Quotes from Goodreads

从 Goodreads 抓取引用并导出为 CSV 和 JSON 格式的项目。

A project for scraping quotes from Goodreads and exporting them in both CSV and JSON formats.

## 项目结构 / Project Structure

```
quotes/
├── fetch_goodreads_quotes.sh    # 抓取脚本 / Scraping script
├── quotes/
│   ├── csv/                      # CSV 格式引用 / Quotes in CSV format
│   │   ├── inspirational.csv
│   │   ├── life.csv
│   │   ├── love.csv
│   │   └── romance.csv
│   └── json/                     # JSON 格式引用 / Quotes in JSON format
│       ├── inspirational.json
│       ├── life.json
│       ├── love.json
│       └── romance.json
└── README.md
```

## 功能特性 / Features

- 从 Goodreads 按标签抓取引用 / Scrape quotes from Goodreads by tag
- 支持分页抓取 / Support paginated scraping
- 导出为 CSV 和 JSON 两种格式 / Export to both CSV and JSON formats
- 随机延迟请求，避免被封禁 / Random delay between requests to avoid being blocked
- 自动清理和格式化数据 / Automatic data cleaning and formatting

## 依赖要求 / Requirements

脚本需要以下工具：/ The script requires the following tools:

- `curl` - 用于 HTTP 请求 / For HTTP requests
- `htmlq` - 用于解析 HTML / For parsing HTML
- `jq` - 用于处理 JSON / For processing JSON

### 安装依赖 / Installing Dependencies

**macOS (使用 Homebrew):**
```bash
brew install htmlq jq
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install curl jq
# htmlq 需要单独安装，参见：https://github.com/mgdm/htmlq
```

## 使用方法 / Usage

### 基本用法 / Basic Usage

```bash
./fetch_goodreads_quotes.sh -t inspirational -m 5
```

### 选项说明 / Options

- `-t, --tag <tag>` - 要抓取的标签 (默认: inspirational) / Tag to scrape (default: inspirational)
- `-m, --max-page <number>` - 抓取的最大页数 (默认: 5) / Max pages to fetch (default: 5)
- `-o, --output-prefix <prefix>` - 输出文件名前缀 (默认: 标签名) / Output filename prefix (default: tag name)
- `-D, --output-dir <dir>` - 输出目录 (默认: quotes) / Output directory (default: quotes)
- `-d, --max-delay-ms <num>` - 请求之间的最大随机延迟，单位毫秒 (默认: 10) / Max random delay between requests in ms (default: 10)
- `-h, --help` - 显示帮助信息 / Show help message

### 示例 / Examples

```bash
# 抓取 "love" 标签的引用，最多 50 页
# Scrape quotes with "love" tag, up to 50 pages
./fetch_goodreads_quotes.sh -t love -m 50

# 抓取 "life" 标签的引用，自定义输出前缀和目录
# Scrape "life" tag quotes with custom prefix and directory
./fetch_goodreads_quotes.sh --tag life --max-page 10 --output-prefix life_quotes --output-dir results

# 增加请求延迟，避免被封禁
# Increase request delay to avoid being blocked
./fetch_goodreads_quotes.sh -t romance -m 20 -d 100
```

## 输出格式 / Output Formats

### CSV 格式 / CSV Format

CSV 文件包含一个标题行和一个 "quote" 列：

CSV files contain a header row and a "quote" column:

```csv
"quote"
"Be yourself; everyone else is already taken." ― Oscar Wilde
"Live as if you were to die tomorrow. Learn as if you were to live forever." ― Mahatma Gandhi
```

### JSON 格式 / JSON Format

JSON 文件包含一个对象数组，每个对象包含一个 "quote" 属性：

JSON files contain an array of objects, each with a "quote" property:

```json
[
  {"quote": "Be yourself; everyone else is already taken." ― Oscar Wilde"},
  {"quote": "Live as if you were to die tomorrow. Learn as if you were to live forever." ― Mahatma Gandhi"}
]
```

## 现有数据 / Existing Data

项目已包含以下类别的引用数据：/ The project already includes quotes in the following categories:

- **inspirational** - 励志引用 / Inspirational quotes
- **life** - 生活感悟 / Life reflections
- **love** - 爱情相关 / Love quotes
- **romance** - 浪漫情感 / Romance quotes

## 注意事项 / Notes

1. **请求频率**：脚本会在请求之间添加随机延迟，建议不要设置过小的延迟值，以免被 Goodreads 封禁 / The script adds random delays between requests. It's recommended not to set too small delay values to avoid being blocked by Goodreads.

2. **数据完整性**：抓取的数据取决于 Goodreads 页面的可用性和结构变化 / The scraped data depends on Goodreads page availability and structure changes.

3. **合法使用**：请遵守 Goodreads 的服务条款和 robots.txt 规则 / Please comply with Goodreads' terms of service and robots.txt rules.

4. **数据来源**：所有引用均来自 Goodreads 网站，版权归原作者所有 / All quotes are sourced from Goodreads, copyright belongs to the original authors.

## 许可证 / License

本项目仅用于学习和研究目的 / This project is for educational and research purposes only.
