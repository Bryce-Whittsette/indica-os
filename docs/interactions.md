# Interactions

Who owns each gesture and how far each one has been checked. Required by `docs/brief/native-fidelity-addendum.md` §20 and §21.

Evidence labels: **sim** means scripted touches on the iPhone 18 Pro simulator (iOS 27.2). **source** means read from code only. **device** means a physical iPhone, and nothing here has that yet. No reference recordings of real iOS have been captured, so nothing here claims one-to-one fidelity.

## Gesture ownership

| Region and state | Owner | Recognition | Wins over | Cancels or falls back to |
| --- | --- | --- | --- | --- |
| Home grid, sideways | `HomePagerTrack` | Touch-down stops any settle. 10 pt of movement, more sideways than vertical | Icon tap, once committed | System cancel settles on the nearest page |
| Home grid, hold | Same track | 0.52 s within 10 pt | Icon tap | Moving past 10 pt ends the hold |
| Search pill | `SearchPagePill` | Tap, or hold 280 ms then drag | Pager, Home editing (high priority) | Moving before the hold ends it. System cancel settles on the nearest page |
| Switcher row | `AppSwitcher` | 10 pt, then one axis per drag | Card tap (`didDrag`) | System cancel returns the row and card |
| App bottom bar | `HybridAppNavigationBar` | 7 pt upward, 30 pt to go Home | Bar buttons | Short drag springs back |
| App content | The app's own views | Scroll, text selection and back as provided by SwiftUI | | |
| Sheets | iOS | System sheet drag | | |
| Top of screen, 82 pt | Shell | Drag down 70 pt | | Opens Notifications on the left, Control Center on the right |
| Bottom of screen, Lock | Shell | Drag up 46 pt | | Unlocks |
| Real top and bottom screen edges | Shell first, then iOS | `defersSystemGestures(on: .vertical)` | First swipe goes to the shell | A second swipe reaches iOS, so a deliberate exit still works |

### Host-app exit policy

- Swift UI doesn't promise confinement. iOS keeps its Home gesture and Control Center. Deferral only asks for a second swipe.
- The shell defers both vertical edges in every state, because each state has an internal edge swipe. The shell also asks iOS to auto-hide its own bar with `persistentSystemOverlays(.hidden)`, but that bar was still visible in simulator captures taken a few seconds after launch.
- **Not established.** The simulator's scripted edge swipe injects the OS gesture directly and left the app on the first swipe, so it can't show whether deferral works. Needs the repeated-gesture run from §21 on a physical iPhone: core apps, keyboard open and closed, counting unexpected exits, wrong transitions, lost input and stuck states.
- **Platform-limited.** With the keyboard up, the bottom of the screen belongs to the keyboard's window, so the shell's swipe can't start there. Dismiss the keyboard first. Notes has Done for this.
- For a single-app demo, [Guided Access](https://support.apple.com/en-us/111795) is optional setup that the person controls. It isn't a substitute for any of this.

## Microinteractions

| Interaction | Trigger and threshold | While moving | Release | Interruption | Haptic | Accessible alternative | Checked |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Page swipe | 10 pt sideways | 1:1 with the finger, from where it was grabbed. Rubber-bands past the ends | Projects velocity, lands at most one page away, critically damped spring carrying release speed | Touch-down stops at the on-screen position | None | Three-finger scroll, pill actions | Sim: tracking, short release, flick. Source: catch mid-settle |
| Page scrub | Hold pill 280 ms, then 44 pt per page | Pages and dots follow continuously. Reversing moves back, nothing queues | Settles on the nearest page, no projection | System cancel settles | Medium on hold, selection per page | Next and Previous page actions on the pill | Sim: mid-page and settle. Source: reversal |
| Search pill tap | Release within 10 pt, before 280 ms | Scales to 0.95 on touch-down | Opens search | Moving cancels | Selection | Default action | Sim |
| Icon press | Touch-down | Scales immediately | Opens on release | Cancelled when the touch becomes a page swipe or a long press | Light on open | VoiceOver button | Sim: opens, flick doesn't open. Source: press cancel |
| Home editing | 0.52 s hold on the grid | Icons wiggle | Done, or hold again | Moving 10 pt cancels | Rigid | Not provided yet | Source |
| Switcher close | Upward drag | Card follows the finger | Closes past 130 pt or on a fast flick, otherwise springs back | System cancel restores | Light | Close action per card | Sim: partial and full from the lower card. Source: rapid flicks |
| Switcher move | Sideways drag | Row follows, resists at the ends | Settles on the predicted card | System cancel restores | None | Three-finger scroll | Sim |
| App to Home | Bar drag or tap | Bar lifts slightly | Goes Home past 30 pt | Short drag springs back | Selection | Home button | Sim: tap. Swipe not rerun since M1 |

**Reduce Motion:** a released page changes in place with no slide. Finger tracking stays, because the person is driving it. Checked in source only.

## Not built or not audited yet

Long-press icon menus, icon rearranging, scroll boundary behavior inside apps, app open and return origin (apps currently scale from the center, not from their icon), and interactive back navigation. The transition into an app also shows an empty wallpaper frame on the simulator, which needs checking on a device.
