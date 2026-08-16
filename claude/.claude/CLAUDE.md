# Global Instructions

## Code Comments: Minimal to None

Write all files and scripts with minimal to no inline comments.

**Do not** use inline comments for documentation, explanation, or justification of code. If code needs explaining, improve the naming and structure instead. Rationale, design decisions, and "why" belong in:

- Memory files
- Committed markdown docs — only when the user has approved creating/updating them

**Exceptions** — only where the language or ecosystem specifically calls for a comment as its standard documentation mechanism:

- Docstrings (Python `"""..."""`, JSDoc/TSDoc, Javadoc, Go doc comments, Rust `///`)
- Public API / interface definitions and exported function signatures
- Directives that must be comments (`# type: ignore`, `// eslint-disable-next-line`, `//go:embed`, shebangs, license headers where required)

These exceptions are case-by-case and language-specific — not a blanket license to comment. A private helper in Python does not need a docstring just because Python has docstrings. Match the comment density of the surrounding code; if the existing file is comment-free, keep it comment-free.

**Verification step (required):** after generating or editing any file, re-read the diff or file and strip any inline comments that crept in. Confirm every remaining comment falls under a listed exception for that specific language. Treat this as a mandatory step before reporting work complete, not an optional cleanup.
