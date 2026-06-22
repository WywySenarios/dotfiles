<!-- Template taken from https://github.com/adamalston/adamalston -->
### Languages

![Python](https://img.shields.io/badge/-Python-000?&logo=Python)
![TypeScript](https://img.shields.io/badge/-TypeScript-000?&logo=TypeScript)
![C](https://img.shields.io/badge/-C-000?&logo=C)
![Java](https://img.shields.io/badge/-Java-000?&logo=Java&logoColor=007396)
![SQL](https://img.shields.io/badge/-SQL-000?&logo=MySQL)

### Technologies

![Docker](https://img.shields.io/badge/-Docker-000?&logo=Docker)
<!-- ![Kubernetes](https://img.shields.io/badge/-Kubernetes-000?&logo=Kubernetes) -->
![Linux](https://img.shields.io/badge/-Linux-000?&logo=Linux)
![Node.js](https://img.shields.io/badge/-Node.js-000?&logo=node.js)
<!-- ![PyTorch](https://img.shields.io/badge/-PyTorch-000?&logo=PyTorch) -->
![Astro](https://img.shields.io/badge/-Astro-000?&logo=Astro)
![React](https://img.shields.io/badge/-React-000?&logo=React)
![Redis](https://img.shields.io/badge/-Redis-000?&logo=Redis)
<!-- ![TensorFlow](https://img.shields.io/badge/-TensorFlow-000?&logo=TensorFlow) -->

<!-- ### Full Stack Projects

[![](https://img.shields.io/badge/-📱%20Website%20and%20app-000)](https://github.com/WywySenarios/Wywy-Website)
[![](https://img.shields.io/badge/-✨%20Async%20semi-autonomous%20agents-000)](https://github.com/WywySenarios/Wywy-Codes) -->

### Experiments

[![](https://img.shields.io/badge/-🚀%20Runtime%20profiling-000)](https://github.com/WywySenarios/Wywy-Codes)
[![](https://img.shields.io/badge/-🐸%20Runtime%20profiling%20agents-000)](https://github.com/WywySenarios/Frog-Jump)

<img height="137px" src="https://github-readme-stats.vercel.app/api?username=WywySenarios&hide_title=true&hide_border=true&show_icons=true&include_all_commits=true&count_private=true&line_height=21&text_color=000&icon_color=000&bg_color=0,ea6161,ffc64d,fffc4d,52fa5a&theme=graywhite" />
<img height="137px" src="https://github-readme-stats.vercel.app/api/top-langs/?username=WywySenarios&hide=html&hide_title=true&hide_border=true&layout=compact&langs_count=6&exclude_repo=comp426,Redventures-Movie-Quotes&text_color=000&icon_color=fff&bg_color=0,52fa5a,4dfcff,c64dff&theme=graywhite" />

---

### Plugins

#### [opencode-rbash](plugins/opencode-rbash)

Restricted bash plugin for opencode with a three-layer defense (allowlist, pipe validation, rbash).

**Installation**

```bash
# 1. Clone with submodules (or init if already cloned)
git clone --recurse-submodules https://github.com/WywySenarios/WywySenarios.git
# or: git submodule update --init --recursive

# 2. Install plugin dependencies
cd plugins/opencode-rbash && npm install

# 3. Register the plugin in .opencode/opencode.jsonc
```

Add to `.opencode/opencode.jsonc`:

```jsonc
{
  "plugins": {
    "rbash": {
      "path": "plugins/opencode-rbash"
    }
  }
}
```

See the [plugin README](plugins/opencode-rbash/README.md) for configuration details.