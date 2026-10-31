# Estée's Greetings

Two small, phone-friendly greeting games for clients, in 中文, BM and English:

- **`christmas/`**: 圣诞小测验. Three questions reveal your Christmas guardian type, with a blessing, a new-year checklist and a WhatsApp reply button.
- **`birthday/`**: 生日惊喜. Open an envelope and play one of four mini-games (cake, balloons, scratch card, catch the blessings).

Each game is a single HTML file with no build step and no tracking. Music and sound effects are generated in the browser.

A personal link can add the language and the recipient's name after `#`, for example `christmas/#zh.<name in base64url>`.

The quiz's tips are general information only, not personal insurance advice.

**`team/`**: a team member enters their name and WhatsApp number and gets their own links. The details travel in the link after `~` (`christmas/#zh~<"name|mobile" in base64url>`), so the client's reply button opens WhatsApp to that team member. Nothing is uploaded.
