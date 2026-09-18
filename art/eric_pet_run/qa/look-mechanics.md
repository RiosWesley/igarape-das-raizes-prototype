# Eric Peresa — look mechanics

Eric is a humanoid explorer with a stable lower body and a flexible upper body. Keep his boots, shorts hem, and backpack base anchored to the same ground line. The eyes lead the gaze, then the eyelids, eyebrows, nose, head and neck turn subtly; preserve facial proportions and do not slide isolated pupils across a fixed white eye. The scarf is soft and follows the head with a small lag. The rigid backpack stays attached to the torso and becomes more side-on as Eric turns.

Cardinal pose families, in screen/viewer coordinates:

- `000 up`: eyes lift toward the top of the screen, chin and forehead angle slightly upward, shoulders stay almost square, scarf lifts a touch.
- `090 screen-right`: nose tip and pupils move clearly to the viewer's right, right cheek becomes more visible, left cheek/ear recedes, backpack remains attached behind the torso.
- `180 down`: eyes and chin angle toward the bottom of the screen, eyelids lower slightly, shoulders remain grounded, scarf folds toward the chest.
- `270 screen-left`: nose tip and pupils move clearly to the viewer's left, left cheek/ear becomes more visible, right cheek recedes, backpack remains attached behind the torso.

For the intermediate 22.5-degree steps, interpolate eyes, eyelids, nose, head turn, scarf lag, and shoulder follow-through evenly between the neighboring cardinal families. The feet, lower torso, and backpack contact remain stable. Do not rotate, skew, or tilt the entire sprite. Each direction must differ visibly from the neutral idle frame while remaining the same person, scale, palette, and silhouette family.
