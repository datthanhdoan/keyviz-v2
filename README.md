![keyviz-2.0](previews/banner.svg)

Keyviz is a free and open-source key visualization software that can display your keyboard and mouse actions in real-time!<br>
Whether you're recording a screen, giving a presentation, or collaborating with a team, you can let your audience see your operations clearly.

This is the English version of Keyviz. For the original version, please visit [mulaRahul/keyviz](https://github.com/mulaRahul/keyviz).

# 🖱️ Keyboard & Mouse Combination

The new version can display mouse operations! In addition to clicks, you can also show keyboard and mouse combinations, such as <kbd>Cmd</kbd> + <kbd>Click</kbd>, <kbd>Alt</kbd> + <kbd>Drag</kbd>, etc.

![key-visualizer](previews/visualizer-bar.svg)

# 🎨 Customization

Say goodbye to monotonous black and white! You can freely adjust the style of the visualization, including style, size, color (regular keys and modifier keys), borders, icons, and more.

![settings-window](previews/settings.svg)

Powerful and easy-to-use settings menu:

- Ignore typing input, only show hotkeys like <kbd>Cmd</kbd> + <kbd>K</kbd> **(default)**
- Choose where to display keys on the screen
- Set how long keys stay on screen
- Multiple entrance and exit animations to choose from

</br>

# 📥 Installation

Go to the [**Github Releases**](https://github.com/zetaloop/keyviz/releases) page to download the latest version, install it or just extract it to use.

Here are more installation channels and usage requirements for various platforms:

<details>

  <summary>🪟 Windows</summary>

### 👜 Microsoft Store (English original version)

You can download the English original version of Keyviz from the [Microsoft Store](https://apps.microsoft.com/detail/Keyviz/9phzpj643p7l?mode=direct).

### 🥄 Scoop (English original version)

```bash
scoop bucket add extras # add the software source first
scoop install keyviz
```

### 📦 Winget (English original version)

```bash
winget install mulaRahul.Keyviz
```

  </br>

  <details>
  <summary>遇到了 <code>*.dll</code> 缺失报错？</summary>

如果在打开软件后出现 `.dll` 文件缺失的错误，这是因为你没安装 Visual C++ 运行库。[点击打开微软 VSC++ 运行库下载页面](https://learn.microsoft.com/zh-cn/cpp/windows/latest-supported-vc-redist?view=msvc-170)。

  </details>

</details>

</br>

<details>

  <summary>🍎 MacOS</summary>

### 🔒 权限

Keyviz 需要 **输入监视** 和 **辅助功能** 权限，请在设置中允许。
</br>

```
系统设置 > 隐私与安全性 > 输入监视/辅助功能
```

  </br>

</details>

</br>

<details>

  <summary>🐧 Linux</summary>

### ❗ v2.x.x 要求

```bash
sudo apt-get install libayatana-appindicator3-dev
```

或

```bash
sudo apt-get install appindicator3-0.1 libappindicator3-dev
```

  </br>

</details>

</br>

# 🛠️ Build Instructions

Before further development and compilation, make sure Flutter is installed on your system. You can refer to the [official installation guide](https://docs.flutter.dev/get-started/install).

After installing and setting up Flutter, clone the repository or download the zip and extract it:

```bash
mkdir keyviz
git clone https://github.com/mulaRahul/keyviz.git .
```

cd to the project folder and start compiling:

```bash
cd keyviz
# Get dependencies
flutter pub get
# Compile executable
flutter build windows
```

</br>

# 💖 Support the Project

Keyviz is a completely free project, and the only source of income is your generous donations, which will help me devote more spare time to developing Keyviz.

</br>
