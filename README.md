# 📸 CleanShot Automation Scripts

## Core Scripts

- `run-cleanshot-flow.sh` - Main pipeline executor
- `rename-last-cleanshot.sh` - Renames screenshots with component tags
- `sort-cleanshots.sh` - Organizes screenshots into component directories
- `log-cleanshot-summary.sh` - Generates daily activity logs

## Usage

```bash
# Single screenshot workflow
bash run-cleanshot-flow.sh <component-name>

# View daily summary
bash log-cleanshot-summary.sh
```

## Directory Structure

```
docs/
└── screenshots/
    ├── [component-1]/
    │   ├── README.md
    │   └── screenshots...
    └── [component-2]/
        ├── README.md
        └── screenshots...
```

## Integration Points

- Raycast Command: "Homy CleanShot"
- CleanShot Save Directory: ~/Desktop/CleanShot-Capture
- Log File: docs/cleanshot-activity.md
