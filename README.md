# 🌙 Đêm Sinh Tồn

[![CI](https://github.com/ndhn27/dem-sinh-ton/actions/workflows/ci.yml/badge.svg)](https://github.com/ndhn27/dem-sinh-ton/actions/workflows/ci.yml)

Game sinh tồn 2D theo kiểu "auto-battler" lấy cảm hứng từ dòng game Vampire Survivors, làm bằng **Godot 4.7**. Nhân vật tự động tấn công, quái xuất hiện ngày càng đông và mạnh theo thời gian — lên cấp để chọn vũ khí/chỉ số mới, xây build và cố sống sót hết thời gian bản đồ.

## Chơi thử

Mở trực tiếp [`index.html`](index.html) bằng trình duyệt là chơi được ngay, không cần cài gì. Hỗ trợ cả bàn phím/chuột (PC) lẫn cảm ứng (di động).

> **Lưu ý:** `index.html` **không phải** bản export web của Godot project bên dưới — đây là một bản triển khai JS/Canvas 2D viết tay riêng, mô phỏng lại cùng thiết kế gameplay (cùng vũ khí, chỉ số, trang bị, quái) để chơi thử nhanh trên trình duyệt mà không cần build Godot. Hai bản được đồng bộ thủ công; nếu sửa gameplay ở bản này, nhớ áp dụng tương tự ở bản kia (`godot-project/scripts/`) nếu muốn cả hai khớp nhau.

## Cách chơi

- **Di chuyển:** WASD / phím mũi tên, hoặc kéo joystick ảo (chạm/kéo chuột)
- **Space:** tạm dừng
- **Shift:** Lướt né — chỉ dùng được sau khi nhặt được trang bị "Ủng Thần Tốc"
- Nhân vật tự động tấn công bằng vũ khí đang trang bị; nhặt đá năng lượng rơi ra từ quái đã hạ để lên cấp
- Mỗi lần lên cấp, chọn 1 trong 3 lựa chọn nâng cấp (vũ khí mới/nâng cấp vũ khí hoặc chỉ số phụ)
- Sống sót đủ thời gian giới hạn của bản đồ đang chọn là thắng

## Bản đồ

| Bản đồ | Mô tả | Thời gian sống sót để thắng |
|---|---|---|
| Bìa Rừng Đêm | Khởi đầu nhẹ nhàng, quái thưa | 6 phút |
| Đầm Lầy Bóng Tối | Quái đông và dai hơn | 10 phút |
| Vực Sâu Vĩnh Hằng | Thử thách khốc liệt nhất | 15 phút |

Mỗi trận còn random thêm 1 trong 5 "biến số đêm": Đêm Bình Thường, Đêm Cuồng Loạn (quái nhanh hơn), Vạn Quái Tề Tựu (quái đông hơn nhưng máu mỏng), Đêm Bạo Tàn (quái đông + trâu + đau hơn), Trăng Máu (trùm xuất hiện sớm và dồn dập hơn).

## Vũ khí

| | Tên | Cơ chế |
|---|---|---|
| 🗡️ | Dao Găm | Bay tới quái gần nhất, xuyên qua nhiều mục tiêu |
| 🥀 | Roi Gai | Quét sát thương hình cung về phía quái gần nhất |
| ❄️ | Hào Quang Băng | Gây sát thương liên tục cho quái ở gần |
| 🌀 | Lưỡi Xoáy | Xoay quanh người, chém mọi quái tiếp xúc |
| ☄️ | Thiên Thạch | Triệu hồi thiên thạch rơi xuống, sát thương diện rộng |
| 🏹 | Cung Ma | Bắn nhiều mũi tên cùng lúc vào các quái khác nhau |

Mỗi vũ khí nâng cấp được tối đa 5 cấp.

## Chỉ số phụ

Đôi Chân Nhanh Nhẹn (tốc độ di chuyển), Sức Mạnh Hắc Ám (sát thương), Nhịp Tim Dồn Dập (tốc độ đánh), Ý Chí Sinh Tồn (máu tối đa), Nam Châm Linh Hồn (phạm vi hút vật phẩm), Máu Bất Tử (hồi máu theo thời gian).

## Trang bị đặc biệt (rơi ra từ Trùm)

- 👢 **Ủng Thần Tốc** — mở khóa khả năng Lướt né
- 🧿 **Bùa Hộ Mệnh** — hồi sinh 1 lần với 50% máu khi gục ngã
- 💍 **Nhẫn Hút Máu** — hồi máu nhỏ mỗi khi hạ gục quái
- 🦔 **Giáp Gai** — phản sát thương lại cho quái chạm vào bạn

## Quái

Zombie (cơ bản), Dơi (nhanh, bay lượn thất thường), Brute (máu trâu, chậm), và Trùm xuất hiện định kỳ theo thời gian trận đấu, càng về sau càng mạnh.

## Công nghệ

- **Godot Engine 4.7**, renderer GL Compatibility (`godot-project/`)
- Toàn bộ thế giới/quái/hiệu ứng vẽ trực tiếp bằng code (`_draw()`), state quản lý bằng Dictionary/Array thuần thay vì scene node riêng cho từng đối tượng — tối ưu cho số lượng quái lớn (tối đa 220 quái cùng lúc)
- `index.html`: bản mirror độc lập bằng vanilla JS + Canvas 2D (xem lưu ý ở mục "Chơi thử" phía trên) — không phụ thuộc Godot runtime, chạy thẳng trên trình duyệt

## Testing / CI

`index.html` có một bộ smoke test headless (`tests/smoke.test.mjs`, dùng `node:test` + jsdom) chạy tự động trên mỗi push/PR qua GitHub Actions (`.github/workflows/ci.yml`). Bộ test này **không** kiểm tra rendering (không có canvas thật trong CI), mà kiểm tra:

- game khởi động không throw lỗi (bắt được lỗi cú pháp, tham chiếu null id, v.v.)
- `startGame()` khởi tạo player đúng (máu đầy, vũ khí ban đầu, mảng state rỗng)
- mô phỏng ~60 giây gameplay liên tục (nhiều tick `update()`) không crash
- lên cấp (`gainXp`), giết quái (`damageEnemy`), và game-over (health về 0) chuyển state đúng

Chạy local:

```bash
npm ci
npm test
```

Chưa có test cho `godot-project/` (GDScript) hay test tương tác bàn phím/cảm ứng — vẫn cần playtest tay cho phần đó.

## Cấu trúc thư mục

```
dem-sinh-ton-godot/
├── index.html              # bản build web, mở là chơi được luôn
└── godot-project/
    ├── project.godot
    ├── Main.tscn
    ├── scripts/
    │   ├── main.gd          # toàn bộ logic gameplay: spawn quái, vũ khí, va chạm, lên cấp, chuyển trạng thái
    │   ├── world.gd         # vẽ thế giới, nhân vật, quái, hiệu ứng
    │   └── hud.gd           # giao diện, joystick ảo, các panel (start/levelup/pause/gameover/victory)
    └── assets/sprites/      # sprite nhân vật, quái, vũ khí, vật phẩm, nền bản đồ
```

## Chạy bằng Godot Editor

Cần **Godot 4.7+**. Mở `godot-project/project.godot` bằng Godot Editor rồi bấm Run (F5).
