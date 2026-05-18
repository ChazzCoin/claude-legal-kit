# Vocabulary — Credibility Levels

How authoritative a source is. Helps weight competing references. Tag format: kebab-case.

## The levels

- **binding** — controlling authority for the relevant jurisdiction. Court has no discretion to disregard. Examples: a SCOTUS opinion in a federal-law matter, the state supreme court's opinion in a matter under that state's law, an applicable statute or rule.

- **persuasive-high** — non-binding authority that a court will give significant weight. Examples: out-of-circuit federal opinion in a federal question case, sister-state opinion on a question of unsettled state law, Restatement of Torts, well-regarded treatise (Wright & Miller, Prosser).

- **persuasive-moderate** — non-binding authority with some weight. Examples: trial-court opinion, secondary source by a known practitioner, AAJ or ABA practice guides.

- **persuasive-low** — non-binding and limited weight. Examples: blog post by a known practitioner, CLE materials, podcast by a credentialed practitioner.

- **informational** — not authority at all, just useful context or commentary. Examples: news article, general-audience podcast, war story from a senior lawyer.

- **expert-opinion** — opinion of a retained expert in our matter. Authority depends on the expert's qualifications and the court's gatekeeping ruling.

- **internal-firm** — our own prior work product. Useful as a starting point or template; never citable to a court.

## Why we track this

So when we pull every reference tagged `damages` + a jurisdiction, we can sort by credibility and put the binding authority on top — not have a podcast episode and a Supreme Court opinion appear as equals.

## What Claude does automatically

- Sorts pulled references by credibility level when surfacing for brief-writing or motion drafting
- Surfaces only `binding` and `persuasive-high` by default when the user asks for "supporting authority" for a filing
- Includes lower-credibility material when the user asks for "all references on X"
- Flags any reference without a credibility level set

## Adding a level

Rare. Discuss before adding.
