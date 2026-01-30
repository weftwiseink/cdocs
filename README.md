# Clauthier

A Claude Code plugin marketplace by [weft](https://github.com/weft).

## Plugins

| Plugin | Description |
|--------|-------------|
| [cdocs](plugins/cdocs/) | Structured development documentation: devlogs, proposals, reviews, and reports |

## Installation

Add the marketplace and enable a plugin in your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "weft-marketplace": {
      "source": {
        "source": "github",
        "repo": "weft/clauthier"
      }
    }
  },
  "enabledPlugins": {
    "cdocs@weft-marketplace": true
  }
}
```

See each plugin's README for detailed usage.

## Local Installation

For rapid iteration on marketplace plugins, or to dogfood changes before publishing, point the marketplace source at a local checkout instead of GitHub:

```json
{
  "extraKnownMarketplaces": {
    "weft-marketplace": {
      "source": {
        "source": "local",
        "directory": "/path/to/clauthier"
      }
    }
  },
  "enabledPlugins": {
    "cdocs@weft-marketplace": true
  }
}
```

Add this to the `.claude/settings.json` of any project that depends on these plugins.
Changes to the local checkout take effect on the next Claude Code session — no reinstall needed.

This is the recommended setup for:
- Developing new plugins or skills against a real project.
- Testing plugin changes before pushing to the repo.
- Running multiple projects with a shared local marketplace.

## License

MIT
