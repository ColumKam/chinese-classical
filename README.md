# chinese-classical

全局行为修饰 Plugin，规定 Claude Code 以简洁实用风格的文言文进行思考，与用户交互时使用现代中文。

## 功能

- **思考语言**：使用简洁实用的文言文进行内部思考
- **交互语言**：所有用户可见内容使用现代中文
- **代码处理**：代码本身保持原样，不强制修改

## 安装

将此目录放置于 Claude Code 的 plugins 目录下：

```bash
# 方法一：复制到 plugins 目录
cp -r chinese-classical ~/.claude/plugins/

# 方法二：使用符号链接
ln -s $(pwd)/chinese-classical ~/.claude/plugins/chinese-classical
```

安装后，每次会话启动时会自动注入指令内容，无需手动调用。

### 验证安装

启动新的 Claude Code 会话，观察是否有以下提示：

```
SessionStart:startup hook success
```

## 工作原理

此 Plugin 使用 `SessionStart` hook 在会话启动时自动注入内容：

1. 会话启动时，`session-start.sh` 脚本被调用
2. 脚本读取 `INSTRUCTION.md` 和 `references/vocabulary.md`
3. 内容以 `<important-reminder>` 标签注入到上下文中

## 目录结构

```
chinese-classical/
├── INSTRUCTION.md              # 主指令文件
├── README.md                   # 本文件
├── references/
│   └── vocabulary.md           # 文言词汇参考
├── .claude-plugin/
│   └── plugin.json             # Plugin 元数据
├── hooks/
│   └── hooks.json              # Hook 配置
└── hooks-handlers/
    └── session-start.sh        # SessionStart hook 脚本
```

## 与 Skill 的区别

这是一个**纯 Plugin**，不是 Skill：

| 特性       | Plugin                     | Skill                |
| ---------- | -------------------------- | -------------------- |
| 加载方式   | SessionStart hook 自动注入 | 根据描述触发调用     |
| 触发条件   | 无需触发，全局生效         | 需要匹配描述才能触发 |
| 出现在列表 | 否                         | 是                   |
| 适用场景   | 全局行为修饰               | 特定任务执行         |

## 使用示例

**思考过程（不可见）**：

```
用户欲创建新文件，当先察目录是否存在。
若目录未存，宜先创建之，然后写入文件。
```

**用户交互（可见）**：

```
我将为您创建一个新文件。首先让我检查目标目录是否存在，然后写入文件内容。
```

## 自定义

### 修改词汇表

编辑 `references/vocabulary.md` 添加或修改文言词汇映射。

### 调整指令内容

编辑 `INSTRUCTION.md` 修改行为规范。

### 调整注入逻辑

修改 `hooks-handlers/session-start.sh` 可以调整注入逻辑。

## 注意事项

- 此 Plugin 修改模型的思考行为，但不影响工具调用和代码生成
- 在紧急情况下（安全相关问题），模型会优先使用清晰的语言而非文言文
- 多语言对话时，思考仍用文言文，交互使用用户所用语言
