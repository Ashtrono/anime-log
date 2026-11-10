# anime.log

A personal anime tracker that runs in your browser. Search MyAnimeList, keep a ranked list with your own scores and notes, and ask an AI what to watch next.

## How to use it

1. **Add anime.** Go to **Add Anime**, search or browse, click a title and press **Add to my list**. Give it a score, status and notes if you like.
2. **Rank your list.** On **My List**, drag rows (or use the arrows) to put your favorites in order. Click any title for details, related seasons, characters and similar shows.
3. **Track progress.** Set a show to *Watching* and use **+1 ep** as you go. It's marked completed when you finish.
4. **Ask the AI.** Open **Settings**, paste an API key from [Anthropic](https://platform.claude.com) or [Google AI Studio](https://aistudio.google.com/apikey), click **Save**, then **Test connection**. In **Ask AI** you can ask for recommendations, or say things like "I finished Frieren, give it a 10" and approve the changes it proposes.
5. **Sync between devices (optional).** Click **Sign in** in the top corner to keep your list on every device. Without an account, your list stays in this browser; use **Export backup** and **Import backup** in Settings to move it.

Make it yours in **Settings → Appearance**: light or dark mode, color themes, side effects and page size. Add your favorite sites under **Search sites** to get a search button on every anime.

## Privacy

- Your list, notes and settings are saved in your browser, and in your account if you sign in. Only you can read your account's data.
- Your AI key stays in your browser. If you choose to sync it, it's encrypted on your device with a passphrase only you know.
- AI chats go straight from your browser to the AI provider you pick.

## Credits

Anime data comes from [AniList](https://anilist.co) by default, with [MyAnimeList](https://myanimelist.net) (through the free [Jikan API](https://jikan.moe)) as a backup. You can switch which one comes first in Settings. This project isn't affiliated with any of them.

Licensed under [MIT](LICENSE).
