# templates/

Document templates Claude starts from when drafting. Organized by document type.

## Subfolders

- `letters/` — client, opposing counsel, and court correspondence
- `pleadings/` — complaint, answer, motion, response shells
- `discovery/` — interrogatories, requests for production, requests for admission, subpoenas
- `orders/` — proposed orders, scheduling orders

## File conventions

- `.docx` for templates with formatting that must be preserved (pleading captions, letterhead)
- `.md` for templates Claude generates fresh prose from
- Placeholders use `{{PLACEHOLDER}}` markers; skills replace them at instantiation
- File name: `<document-type>-<variant>.docx` (e.g., `complaint-personal-injury.docx`, `motion-summary-judgment.docx`, `letter-client-engagement.docx`)

## Status

Empty subfolders for now. Templates get added as we build the corresponding drafting skills.
