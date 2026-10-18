# Katkı Kuralları

Bu repoda çalışan herkes için kurallar. İlk commit'inden önce lütfen oku.

## Temel kurallar

1. **`main` dalına doğrudan push yok.** `main` her zaman derlenen ve çalışan halde kalmalı.
2. **Her iş için ayrı branch.** Branch'ler küçük olsun, çabuk merge edilsin.
3. **Her değişiklik Pull Request ile gelir** ve en az bir ekip arkadaşı tarafından incelenir.
4. **`main`'i sık sık çek**, diğerlerinden uzaklaşma.

## Katkı oranı (önemli)

Ödev gereği her üye GitHub'da contributor olarak görünmeli ve kodun **en az %5'ini** yazmış olmalı.
Bu oran GitHub istatistiklerinden ölçülür, o yüzden:

- Herkes **kendi bilgisayarından, kendi hesabıyla** commit atar. Başkasının kodunu onun adına commit'leme.
- Commit e-postan GitHub hesabına bağlı olmalı, yoksa commit'ler sana sayılmaz:
  ```bash
  git config user.name  "<github-kullanıcı-adın>"
  git config user.email "<GitHub hesabına bağlı e-posta>"
  ```
  E-postanı gizlemek istersen GitHub → Settings → Emails sayfasındaki
  `<id>+<kullanıcı>@users.noreply.github.com` adresini kullan.

## Branch isimleri

| Önek        | Ne için                    | Örnek                    |
|-------------|----------------------------|--------------------------|
| `feature/`  | Yeni özellik               | `feature/login-screen`   |
| `fix/`      | Hata düzeltme              | `fix/sqlite-migration`   |
| `docs/`     | Sadece doküman / rapor     | `docs/hafta-07`          |

## Günlük akış

```bash
# 1. Güncel main'den başla
git checkout main
git pull

# 2. Branch aç
git checkout -b feature/<iş-adı>

# 3. Çalış, sonra commit at
git status
git add <dosya1> <dosya2>
git commit -m "Kısa ve açık mesaj"

# 4. Push et (-u sadece ilk push'ta)
git push -u origin feature/<iş-adı>
git push

# 5. Gerekirse main'deki yenilikleri kendi branch'ine al
git pull origin main
```

Sonra GitHub'da **"Compare & pull request"** butonuyla PR aç.

## Commit'ler

- Bir commit, tek bir mantıklı değişiklik.
- Mesaj neyi yaptığını söylesin: `Add note list screen`, `Fix crash on empty database`.
- `git add .` yerine `git add <dosyalar>` kullan, yanlışlıkla dosya gitmesin.
- Build çıktıları (`build/`, `.dart_tool/`) ve IDE dosyaları commit'lenmez.

## Pull Request'ler

- Başlık: değişikliğin kısa özeti.
- Açıklama: PR şablonunu doldur (ne değişti, nasıl test edildi, varsa `Closes #<issue>`).
- Review istemeden önce:
  ```bash
  flutter analyze
  dart format .
  flutter test
  ```
  ve uygulamanın emülatörde açıldığından emin ol.
- Onay gelince PR'ı açan kişi merge eder ve branch'i siler.
- PR'lar haftalık raporda kimin ne yaptığını göstermek için de kullanılır. Haftalık rapora
  o hafta merge edilen PR'ların linklerini ekle.

## Kod

Sunumda kaynak koddan soru gelebilir. Kod okunabilir olsun ve herkes kendi yazdığı kısmı
anlatabilsin.
