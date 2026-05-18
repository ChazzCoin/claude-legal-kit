# Vocabulary — Sensitivity Levels

Confidentiality posture of a record. Drives how Claude handles transmission, sharing, and copying. Tag format: kebab-case.

## The levels

- **public** — freely available to anyone on the internet or in published form. No confidentiality concern. Examples: court opinions, public podcasts, law review articles, news articles, statutes, regulations, court rules.

- **paywalled-public** — published, but behind a subscription or paywall (Westlaw, Lexis, paid CLE recordings, paid journals). Still "public" in the sense that anyone with a subscription can access. Tag separately because reproduction may implicate license terms.

- **client-shared** — material the client has shared with the firm that is not itself privileged (medical records, contracts, employment records, insurance policies). Not freely shareable — protected by representation but not by attorney-client privilege.

- **work-product** — attorney work product. Mental impressions, analysis, theories, strategies. Internal to the firm. See [`rules/privilege.md`](../shared-library/rules/privilege.md).

- **privileged** — attorney-client privileged communications. Highest protection — never transmitted externally without explicit confirmation. See [`rules/privilege.md`](../shared-library/rules/privilege.md).

- **sealed** — under a protective order or sealed by court order. Handle per the order. Document the order in the record's notes field.

- **third-party-confidential** — confidential under an NDA, protective order, or similar agreement with a non-client third party.

## Handling rules

| Level | External transmission | Local copy | Quote in firm work product |
|---|---|---|---|
| public | OK with attribution | OK | OK with attribution |
| paywalled-public | Per license terms | Per license terms | OK with attribution |
| client-shared | Only per client direction | OK in matter folder | OK in firm work product (privileged) |
| work-product | Never without confirmation | OK | OK |
| privileged | Never without confirmation | OK | OK |
| sealed | Per court order | Per court order | Per court order |
| third-party-confidential | Per agreement | Per agreement | Per agreement |

## What Claude does automatically

- Refuses to transmit `privileged`, `work-product`, `sealed`, or `third-party-confidential` material externally without explicit confirmation
- Adds the privilege header to new `work-product` and `privileged` documents
- Flags any reference that doesn't have a sensitivity level set
- Surfaces sealed-document handling rules whenever a sealed record is touched

## Adding a level

Adding a new sensitivity level is rare — it changes handling rules. Discuss before adding.
