# How to Cite — Modified Bluebook Format

The firm uses a **modified Bluebook** style for all Research Library records. The modifications: more dates than standard Bluebook (so we can always trace what we knew when), and standardized URL + archive URL treatment.

## The principle

**More detail is better than less.** Especially dates. A citation should always answer:
- *What* is being cited
- *Who* created it
- *Where* it was published
- *When* it was published
- *When* we accessed it
- *Where* to find it now (live URL)
- *Where* to find it forever (archive URL)

## Standard date fields on every Reference

| Field | Definition | Format |
|---|---|---|
| `publication_date` | When the source was first published or released | YYYY-MM-DD |
| `date_accessed` | When we first looked at it | YYYY-MM-DD |
| `date_added` | When we added it to the library | YYYY-MM-DD |
| `date_last_reviewed` | Last time someone re-confirmed its accuracy/availability | YYYY-MM-DD |
| `date_archived` | When the Wayback snapshot was captured | YYYY-MM-DD |
| `date_superseded` | If superseded, when | YYYY-MM-DD or null |

All dates ISO 8601 (YYYY-MM-DD). No "March 9, 2026" forms in JSON. The human-readable .md companion can convert to long-form.

## Citation strings by source type

### Court opinion (binding or persuasive)

Standard Bluebook for the cite itself. Add `date_accessed` and `archive_url` in the record but not in the citation string itself.

```
Hickman v. Taylor, 329 U.S. 495 (1947).
```

```
Smith v. Jones, 123 So. 3d 456 (Ala. 2024).
```

### Statute or rule

Standard Bluebook.

```
Fed. R. Civ. P. 26(b)(3).
Ala. Code § 6-5-410 (1975).
```

### Law review article

Standard Bluebook + URL and date accessed if web-accessed.

```
Jane Doe, The Dignity of Damages, 67 Ala. L. Rev. 123 (2024).
```

### Trade magazine / journal article

```
John Smith, Closing the Damages Gap, Trial Magazine, June 2025, at 24.
```

### Book or treatise

```
Charles A. Wright et al., Federal Practice and Procedure § 2024 (3d ed. 2010).
```

### Podcast episode (modified Bluebook — firm convention)

```
Picking Justice, Keith Mitnik – What Package Are You Delivering to Jurors?, Episode 29 (Mar. 9, 2026), https://www.pickingjustice.com/episode/29 (last visited May 15, 2026).
```

Pattern:
```
<Show Name>, <Episode Title>, Episode <N> (<Publication Date>), <Live URL> (last visited <Date Accessed>).
```

### CLE recording

```
<Provider>, <Title>, <Speaker(s)> (<Date>), <URL if available> (last visited <Date>).
```

### Blog post or website

```
<Author>, <Post Title>, <Site Name> (<Date>), <URL> (last visited <Date>).
```

### Video (YouTube, Vimeo, etc.)

```
<Channel / Creator>, <Title>, <Platform> (<Date>), <URL> (last visited <Date>).
```

### Internal work product

```
[Firm Internal] <Author>, <Title>, <Matter Name if applicable>, <Date>.
```

Internal work product is never cited externally — this string is for internal cross-reference only.

## What "last visited" means

The `date_accessed` is when we *most recently confirmed the URL still resolves to the cited content*. If a Reference gets re-reviewed and the URL still works, update `date_accessed` and `date_last_reviewed`. If the URL is dead, the archive URL takes over as the primary cite and we add a note.

## Archive URL convention

Every web-based Reference also gets an archive URL. Format:

```
https://web.archive.org/web/<YYYYMMDDHHMMSS>/<original-URL>
```

In the human-readable citation, the archive URL appears in brackets after the live URL when the live URL is no longer reliable:

```
... https://www.pickingjustice.com/episode/29 [archived: https://web.archive.org/web/20260515.../https://www.pickingjustice.com/episode/29] (last visited May 15, 2026).
```

While the live URL still resolves, the archive URL stays in the record but is not displayed in the citation string.

## What Claude does automatically

- Generates the citation string when creating any Reference
- Maintains all date fields and updates `date_last_reviewed` on every re-touch
- Substitutes the archive URL into the citation string when the live URL is detected as dead
- Flags any Reference whose `date_last_reviewed` is more than a year old (suggests a sweep)
