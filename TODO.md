# Todo

See [the live version](https://joplin.wcyat.me/shares/2kmfXm9Xi18qDxGbaFJq4Y)

- [ ] server & frontend: notifications
	- save in db
	- starred threads / threads created by the user: new comments
	- comments created by the user: replies, emotions
	- [web-push](https://www.npmjs.com/package/web-push)

- [ ] frontend: admin dashboard
	- [ ] create/edit categories
	- [ ] ban / unban users
	- [ ] delete / edit threads
	- [ ] logs (e.g. new users, new threads)

- [ ] frontend & server: admin config (config.json)
	- [ ] register modes (  normal / regex email / none / invite )
	- [ ] visibility: internal / public
	- [ ] frontend fetch server config (GET /api/server/info /api/server/config etc.)

- [ ] server & frontend: comment types (poll/image/video etc.)

  - [ ] poll (maybe special html tag, e.g. `<poll></poll>`)
  - [ ] image
  - [ ] video
  - [ ] markdown / rich text
  - [ ] quizzes
    - [ ] crossword
    - [ ] mc
  - [ ] games?
    - [ ] 24 game
    - [ ] tic tac toe
  - [ ] referendum (can only be created by admin)

- [ ] server & frontend: recall / search / starred / history improvements
	- [ ] search in recall
	- [ ] delete viewed threads records
	- [ ] search by thread id
	- [ ] sort by popularity

- [ ] server & frontend: admin reply, ban/unban users, follow/unfollow users
	- [ ] ban : { admin: { }, reason: string, expire: date }

- [ ] frontend: implement category tags (in sidebar), category create/edit (in admin dashboard), see [api](https://docs.metahkg.org/docs/api/v5.1-dev)

- [ ] frontend: implement admin edit, delete threads/comments, mute/unmute users (see [api](https://docs.metahkg.org/docs/api/v5.1-dev) admin session)

- [ ] frontend: material design, rounded corners, more colorful, & redesign sidebar

- [ ] frontend: improve thread list
  - [ ] rounded
  - [ ] button in bottom right corner (e.g. delete, star)

- [ ] report comments

- [ ] otp login

- [ ] icon buttons: outlined when inactive; filled when active

- [ ] api tokens (custom expiration)

- [ ] react-motions (for scrolling)

- [ ] thread tabs

- [ ] (frontend) framework for user pages

- [ ] api change config (config.json)

- [x] save login sessions and allow remove (the auth token must be found in db to be valid)

```typescript
{
	sessions: [
		{
			token: string, # jwt
		    date: Date,
			exp: Date
		}
	]
}
```

- [ ] tags for threads (reddit/stackoverflow style)

- [ ] auto run migrate script (save previous version in a file)

- [x] POST /users (admin create user)

- [x] POST /threads

- [ ] tooltip preview image link (check if is .jpg/png)

- [ ] react-toastify

- [x] alerts using mui alerts

- [ ] double editor (markdown / rich text)

- [ ] switch to froala ?

- [ ] mailcow

- [x] move thread / comment to removed collection after deleting

- [x] mute : { admin: { }, reason: string, expire: date }

- [x] admin : { edits : [{ admin: { id: 1, name: "wcyat" }, reason: string }], replies: [{ admin: { }, reply: string }]

- [x] add pinned: boolean to category

- [x] service worker for rlp.metahkg.org

- [x] admin edit (add the words edited by admin under the commrnt)

- [x] disallow same title

- [ ] tag users (e.g. @wcyat

- [ ] multiple pinned comments

- [ ] picture in picture player as a snackbar

- [ ] star sort by last comment and reverse star time

- [x] streamable

- [ ] pm

- [ ] light mode

- [ ] i18n

- [ ] generate html title and description from server

- [x] generate sitemap from server

- [x] add tags to categories

- [ ] tinymce image editor

- [x] Avatar editor show zoom and degree, max zoom 5x

- [x] avatar editor

- [x] star, unstar

- [x] emotions

- [ ] fully block (hide threads and all comments, including in quotes)

- [x] block users should work in quotes

- [ ] option to set page limit (frontend)

- [ ] [animate.css](https://animate.style) for animations (e.g. image resize)

- [ ] pin threads

- [ ] convert html to text and shortened versions

- [ ] about dialog

- [ ] get user's previous comments (maybe /api/users/{id}/comments)

- [ ] markdown editor (maybe codemirror?)

- [x] add create category & add createdAt to category object

- [x] reactions

- [ ] handle synchronous requests that occur at a perfectly same time (see https://stackoverflow.com/questions/21218651/mongodb-auto-increment-id)

- [ ] videojs

- [x] improve pagify (scroll to bottom after page change)

- [ ] improve the replies popup (more alike that of lihkg)

- [ ] delete view thread history

- [x] react swipable view

- [ ] vote button --> not logged in --> login popup

- [ ] ig / fb / reddit embed (ig and fb done)

- [ ] if unseen add yellow dot

- [ ] ~~use elastic/open search~~ (cancelled for high memory use)

- [ ] spam detection

- [ ] word limit

- [ ] reset password (backend done)

- [ ] del acc

- [ ] overview (total posts users etc.)

- [ ] improve log out (no need navigate)

- [ ] pm <https://github.com/guptasajal411/instant-chat-app/>

- [ ] log in dialog

- [x] block users

- [ ] terms, privacy

- [ ] <https://github.com/cyrilwanner/react-optimized-image>

- [ ] <https://www.npmjs.com/package/react-grid-gallery>

- [x] user crop profile image

- [x] onclick -> confirm dialog (Please choose file format: jpg xxx yyy, file limit: 200k, confirm) -> upload selector (file explorer)

- [x] react-images

- [ ] react-photo-gallery

- [x] mode based menu ("profile" | "menu" | "recall")

- [x] react-social-media-embed

- [ ] male & female custom colors

- [ ] admin: visibility (users only / everyone)

- [ ] add should fold / should hide in comments (blocked)

- [ ] render comments on visible

- [x] react-avatar-editor

- [ ] react-native-fast-image

- [ ] rc-image

- [x] change global total votes on vote

- [ ] https://github.com/bvaughn/react-virtualized

- [x] ~display block for image loaders~

- [x] add streamable

- [ ] quote & add comment to another thread (use a dialog to choose thread)

- [ ] slack-like comments

- [x] Admin management api

- [ ] use a global color theme

- [x] functions for quickly switching menu mode

- [ ] if in quote do not add treat as normal photo

- [ ] move to nextjs?

- [ ] registration modes (backend done: see [docs](https://docs.metahkg.org/docs/customize/registermode)),

- [ ] preview comment when creating

- [x] if (croot.clientHeight / 5 + {pagetop’s height} > croot.clientHeight) { no change? }

- [x] add telegram group link

- [x] use a lighter color in menu for current thread

- [x] || hover

- [x] use M/F for sex and U/D for votes

- [x] category yellowed if currently on

- [x] improve returnto (window.location.href.replace(window.location.origin, ‘’) ?)

- [x] ~~use \[deleted\] to decomplicate~~

- [x] use removed: true in api to decomplicate

- [x] ask for env variables input and put to .env

- [x] signin /register with metahkg logo

- [x] jsx element for logo

- [x] compress avatar (img-reduce-size-js)

- [x] alerts (logged out, not found…)

- [x] twitter/youtube embed

- [x] unify alerts / shares

- [x] 404 page

- [x] telegram admin bot

- [x] recall

- [x] a link for every comment (use timeout and scrollintoview)

- [x] add a page switch at bottom right corner

- [x] mobile dock

- [x] resend confirmation

- [x] docker

- [x] don’t use aws (gravatar / local ?)

- [x] mobile show long date on click

- [x] api for some of the comments not whole page

- [x] html sanitize

- [x] improve api (more restful)

- [x] add target="\_blank" to links

- [x] replies

- [x] quote: fetch from api

- [x] upload images (na.cx)

- [x] update menu after adding comment / creating topic

- [x] add paper for share link bar

- [x] pagebottom (~~terms, privacy,~~ gitlab…)

- [x] move to recaptcha

- [x] stop linearprogress 1 second after ready

- [x] node-html-parser

- [x] jwt

- [x] adult category

- [x] settings

- [x] go to last viewed comment on next visit

- [x] current comment

- [x] react-photo-gallery

- [x] change username

- [x] change secondary color in settings

- [x] start and set up mongodb before starting server

- [x] pin message

- [x] link preview @dhaiwat10/react-link-preview
