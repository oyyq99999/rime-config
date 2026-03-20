# Rime Config - 拼音加加五笔整句

这是一个基于 Rime 输入法框架的个人配置方案，主要特点是结合了 **拼音加加双拼** 和 **五笔 86 辅码**，旨在提供高效的整句输入体验。

## 主要特性

*   **拼音加加双拼方案**：内置经典的拼音加加双拼逻辑（基于 `double_pinyin_pyjj`）。
*   **五笔 86 辅码筛选**：在拼音输入的同时，支持使用五笔 86 编码作为辅码进行过滤，显著提高重码选择效率。
*   **超大字符集支持**：支持 Unicode 17 字符集，涵盖了绝大多数罕见字，词库经过优化处理。
*   **LUA 增强逻辑**：通过自定义 LUA 脚本（`fuma_selector.lua`, `fuma_filter.lua`）实现灵活的辅码过滤与选择。
*   **多方案支持**：
    *   `caspal_pyjj_wubi`: 拼音加加五笔整句（核心主方案）。
    *   `double_pinyin_pyjj`: 拼音加加双拼。
    *   `caspal_wubi86`: 基础五笔 86 方案。
*   **丰富词库资源**：集成了包括 `luna_pinyin` 扩展词库在内的多种词典资源，满足不同场景下的输入需求。
*   **自动化数据生成**：核心词库数据由 [rime-pyjj-wubi](https://github.com/oyyq99999/rime-pyjj-wubi.git) 子项目自动化生成，整合了上游多个优质词库源。

## 目录结构

*   `caspal_pyjj_wubi.schema.yaml`: 主方案定义文件。
*   `caspal_pinyin_unicode17.dict.yaml`: 核心拼音词库。
*   `caspal_wubi_fuma.dict.yaml`: 五笔辅码词库。
*   `default.custom.yaml`: 全局自定义配置（如方案列表、按键绑定）。
*   `lua/`: 存放 LUA 扩展脚本。
*   `data/rime-pyjj-wubi/`: 数据生成引擎（子模块），负责整合上游词库数据。
*   `opencc/`: 存放 OpenCC 繁简转换及 Emoji 配置文件。

## 安装与使用

1.  **准备环境**：确保已安装 Rime 输入法（如 macOS 下的 [鼠须管 Squirrel](https://github.com/rime/squirrel)，Windows 下的 [小狼毫 Weasel](https://github.com/rime/weasel)）。
2.  **克隆仓库**：将本仓库克隆到 Rime 的用户配置目录：
    *   macOS: `~/Library/Rime`
    *   Windows: `%APPDATA%\Rime`
    *   Linux: `~/.config/ibus/rime` 或 `~/.config/fcitx/rime`
3.  **更新子模块**：执行以下命令以获取数据生成工具：
    ```bash
    git submodule update --init
    ```
4.  **构建数据** (可选)：如果需要重新生成或更新词库，请参考 `data/rime-pyjj-wubi/README.md`。
5.  **部署配置**：在输入法菜单中选择“重新部署” (Deploy) 以加载新配置。

## 致谢

本项目的数据源和逻辑参考了以下优秀的开源项目：
- [rime-wubi](https://github.com/rime/rime-wubi)
- [pinyin-data](https://github.com/mozillazg/pinyin-data)
- [jieba](https://github.com/fxsjy/jieba)
- [rime-emoji](https://github.com/rime/rime-emoji)

详细的第三方组件及其许可证信息请参见 [LICENSE](LICENSE)。

## 许可证

本项目遵循 [GPL-3.0](LICENSE) 开源许可协议。
