# Posture Tracker App - Teammate Onboarding

Use this quick setup after cloning the repository.

## Web (React/Vite)

```bash
npm install -g pnpm   # once
pnpm install
pnpm dev
```

## Flutter

Machine-level setup: each teammate does this once on their own machine.

```bash
# Install puro: https://puro.dev
puro create env stable
puro use env
flutter doctor         # fix any issues it flags
flutter run
```

The https://puro.dev docs tell teammates how to install Puro for their OS.
This is the correct way to handle machine-level dependencies in a shared repo.

## Notes

- Commit and share repo files only.
- Do not commit machine-level installs, local SDK binaries, or global PATH changes.
- `pnpm-lock.yaml` should be committed for reproducible web installs.
