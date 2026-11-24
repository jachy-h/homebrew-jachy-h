# AGENTS.md

本文件是本仓库的项目级规范，适用于所有在本仓库工作的 AI Agent 与协作者。
与全局规范冲突时，以本文件为准；与 Homebrew 官方规范冲突时，以 Homebrew 官方规范为准。

## Project Purpose

- 本仓库是 Jachy 的个人 Homebrew Tap：`jachy-h/homebrew-jachy-h`，用户侧 Tap 名称为 `jachy-h/jachy-h`。
- 唯一职责是 **软件分发**：Formula、Cask、安装说明、版本更新与相关自动化。
- 每个软件都维护在独立源码仓库中（例如 Umbragate 在 `jachy-h/umbra-gate`）。
  本仓库不承载软件主体源码、构建脚本或前端资源。
- 当前包含两个真实软件包：`umbragate` 与 `lan-copy`（均为 Formula）。不要虚构软件、版本、下载地址或 SHA256。

## Repository Architecture

```text
Formula/     # 命令行工具、后台服务等适合 Formula 分发的软件
Casks/       # macOS GUI 应用、DMG、PKG 等适合 Cask 分发的软件（当前不存在，无需创建）
.github/workflows/
  validate.yml   # 只读校验：PR 与 main 分支
AGENTS.md
README.md
```

约定：

- 遵循 Homebrew Tap 原生目录结构，**不要**为每个软件创建子目录。
- 定义文件直接放在 `Formula/` 或 `Casks/` 根下，文件名必须是小写 token
  （`^[a-z0-9][a-z0-9+@._-]*$`），类名由 Homebrew 规则从文件名推导。
- 目录为空时不要提交 `.gitkeep` 占位文件；等真的有 Cask 时再创建 `Casks/`。
- `README.md` 面向最终用户（安装、升级、卸载、信任说明）；
  维护者与 Agent 的规则写在本文件，不要混入 README。

## Development Rules

- 修改前先阅读：对应 Formula/Cask 全文、`.github/workflows/` 下的工作流、
  上游软件仓库的 Release 说明与发布工作流。
- 优先最小化修改。能改一行就不要重构，能保持现状就不要引入抽象。
- 不随意改变现有软件的下载地址、安装路径、服务定义与 caveats。
- 不复制软件源码、构建产物或大体积二进制到本仓库。
- 不引入与 Tap 维护无关的依赖、脚本、CI 框架或包管理器抽象。
- 不创建没有实际用途的目录、占位文件或抽象层。
- 保持 `README.md` 的 Available Packages 表格与仓库真实内容一致。
- 不修改 Git 历史（不 rebase/force push 已发布的提交），不在未授权情况下提交或推送。

## Adding a Formula

1. 确认软件已有正式 Release（GitHub Releases 等），且产物是稳定、可复现的归档文件。
2. 确认下载文件的实际内容与架构支持（Apple Silicon `arm64` / Intel `x86_64`）；
   macOS only 软件要显式区分架构，不要用含糊的 `on_macos` 通配逻辑。
3. 从可信发布流程获取 SHA256（优先使用发布流程生成的校验文件），或本地下载后计算
   `shasum -a 256 <file>`；禁止凭记忆或推测填写。
4. 创建 `Formula/<name>.rb`，包含 `desc`、`homepage`、`url` + `sha256`、`license`、
   `install`、必要的 `service`、以及真正能验证安装结果的 `test`。
   URL 中已含版本号时不要额外写 `version`（`brew audit --strict` 会报冗余）。
5. 编写测试：在 `test do` 中执行本仓库安装出来的二进制，并断言真实输出片段。
6. 执行 `brew audit --strict`（见 Validation Commands），必须零问题。
7. 执行 `brew style`，必须零 offense。
8. 确认 CI（`.github/workflows/validate.yml`）在 PR 上通过后再合并。

## Adding a Cask

1. 确认软件提供正式安装包（`.app` / DMG / PKG / zip），且来源是官方发布渠道。
2. 确认应用名称、`app` 安装方式与 Bundle ID（`brew info --cask <name>` 或
   `mdls -name kMDItemCFBundleIdentifier <app>` 验证）。
3. 确认支持的最低 macOS 版本（必要时声明 `depends_on macos: ">= :sonoma"`）。
4. 获取安装包的 SHA256；不要使用 `sha256 :no_check` 绕过校验。
5. 编写 `Casks/<name>.rb`，明确 `version`、`sha256`、`url`、`name`、`desc`、
   `homepage`、`app`（或 `pkg`）；需要清理用户数据时补全 `uninstall` 与 `zap`。
6. 执行 `brew audit --strict --cask` 与 `brew style`，两者均需零问题。
7. 不要为了统一而把 GUI 应用强行改写成 Formula，反之亦然。

## Updating Packages

更新版本时必须逐项确认，缺一不可：

- 目标 Release 确实存在（`gh release view <tag> --repo <owner/repo>`），且不是 draft/prerelease（除非有意发布预发布版）。
- 下载 URL 可访问，且指向该 Release 的真实产物（`curl -I` 或 `gh release download`）。
- 更新后的 SHA256 来自实际下载文件或发布流程产出的校验文件，并与产物一一对应。
- 检查架构覆盖：`arm64` 与 `x86_64` 各自的 URL 与 SHA256 必须分别正确，不能张冠李戴。
- 验证安装逻辑仍然成立（归档内的路径/文件名是否变化，例如 `bin`、`pkgshare` 的内容）。
- 不得猜测 SHA256、不得复制上一次的校验值、不得为了让安装通过而放宽校验。

## Release and Automation

- 软件发布与 Tap 更新是 **两个独立流程**：
  - 软件仓库负责编译、打包、上传 Release 产物并生成 `sha256sums.txt`。
  - Tap 仓库负责把版本号、下载 URL、SHA256 落到 Formula/Cask。
- 当前 Umbragate 的自动更新由上游 `jachy-h/umbra-gate` 的
  `.github/workflows/release.yml`（`update-homebrew-tap` job）完成，使用该仓库的
  `HOMEBREW_TAP_TOKEN` Secret 检出并推送本仓库。
- Lan Copy 的自动更新由上游 `jachy-h/lan-copy` 的 `.github/workflows/release.yml`
  （`homebrew` job）完成：从 Release 的 `SHA256SUMS` 取 macOS Apple Silicon 归档校验值，
  只改写 `Formula/lan-copy.rb` 的 `url` 与 `sha256`，推送前在本机 Tap 上执行
  `brew style` 与 `brew audit --strict --online`，同样使用 `HOMEBREW_TAP_TOKEN`。
  该公式只支持 macOS Apple Silicon，`license` 依赖上游仓库的 MIT `LICENSE`。
- 本仓库的 `.github/workflows/validate.yml` 只做只读校验：`permissions: contents: read`，
  不使用任何 Secret，不允许写入仓库。
- 自动化必须保留验证环节：更新后仍要通过 `brew audit --strict` 与 `brew style`。
- 不得在代码、日志、工作流输出中打印或回显 Token；使用 GitHub Secrets 与环境变量传递。
- 修改自动更新流程时，必须同时检查：目标仓库名称、Actions 权限、触发条件、
  提交人身份、推送权限，以及重命名仓库后旧引用是否仍然有效。

## Security Rules

- 不允许关闭或绕过 SHA256 校验来解决下载问题。
- 不允许把 `sha256 :no_check` 作为默认解决方案；Formula 中禁止出现
  （`validate.yml` 会直接失败）。
- 不允许执行来源不明的安装脚本（`curl | sh`、临时远端脚本等）。
- 不允许把 Secret、Token、私钥写入仓库、提交信息或日志。
- 自动化权限遵循最小权限原则：只读校验工作流不得持有写权限或 Secret。
- 修改 Tap 信任相关配置（`brew trust` 相关说明）时，必须在说明中明确影响范围，
  不得暗示 Tap 信任等同于 Apple 公证或安全审计。

## Validation Commands

按适用性选择，不需要每次都全部执行：

```bash
# 语法（任何修改都适用，最快）
ruby -c Formula/*.rb
[ -d Casks ] && ruby -c Casks/*.rb

# 代码风格（可传路径，无需先 tap）
brew style Formula
[ -d Casks ] && brew style Casks

# 审计：Homebrew 已禁用 `brew audit <path>`，必须用 tap 名称
brew tap jachy-h/jachy-h                                   # 首次执行
brew trust --tap jachy-h/jachy-h                            # 首次执行（Homebrew 6+）
brew audit --strict --formula jachy-h/jachy-h/umbragate
brew audit --strict --online --formula jachy-h/jachy-h/umbragate   # 额外校验 URL/homepage，需要网络
brew audit --strict --cask jachy-h/jachy-h/<name>          # 仅当存在 Cask 时

# 安装验证：会真实改动本机环境，仅在确认需要时执行
brew install --build-from-source jachy-h/jachy-h/umbragate
brew reinstall --build-from-source jachy-h/jachy-h/umbragate   # 已安装时
```

说明：

- `brew audit` 的路径参数在较新 Homebrew 中已被禁用；本地审计前必须先 `brew tap` 并 `brew trust`。
  若不愿污染本机 Tap 状态，可用符号链接临时注册 Tap，并在结束后删除链接与信任条目。
- `brew install --build-from-source` 不是每次修改都必需。仅在改动 `install`、`service`、
  `caveats` 或归档内容时执行；纯版本/SHA256 更新可用 `brew install` + `brew test` 验证。
- CI 只跑语法、布局、`brew audit --strict --online` 与 `brew style`，不跑真实安装。

## Agent Workflow

所有 Agent 执行任务时按以下顺序进行：

1. 先检查当前 Git 状态（`git status`、`git log --oneline -5`），确认工作区是否干净。
2. 阅读相关定义文件、工作流与上游发布信息，明确当前行为基线。
3. 明确本次修改的影响范围（会不会改变用户安装行为、服务定义、信任要求）。
4. 修改后执行适用的验证命令，记录真实输出，不臆造通过结果。
5. 检查 `git diff`，确认没有意外文件、格式噪音或敏感信息。
6. 总结：修改内容、验证结果、遗留问题与需要人工完成的事项。

不要未经用户授权直接提交（commit）、推送（push）、创建 Release 或修改 GitHub 仓库设置。

## Known Operational Notes

- 本仓库历史名称是 `homebrew-umbragate`，已重命名为 `homebrew-jachy-h`。
  上游 `jachy-h/umbra-gate` 的 `release.yml` 仍然写 `repository: jachy-h/homebrew-umbragate`，
  依赖 GitHub 的重定向才能工作；应更新为 `jachy-h/homebrew-jachy-h`（需在软件仓库中修改，
  属于跨仓库改动，需用户授权）。
- 老用户若曾 `brew tap jachy-h/umbragate`，重命名后需要重新
  `brew tap jachy-h/jachy-h` 并重新 `brew trust --tap jachy-h/jachy-h`；
  旧的信任状态不会自动迁移。
