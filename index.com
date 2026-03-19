<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Казахская Империя | Minecraft</title>
    <style>
        /* CSS СТИЛИ (Оформление) */
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
        body { background-color: #1a1a1a; color: white; line-height: 1.6; }
        .screen { min-height: 100vh; display: flex; flex-direction: column; }
        
        /* Авторизация */
        #auth-screen { justify-content: center; align-items: center; background: linear-gradient(rgba(0,0,0,0.7), rgba(0,0,0,0.7)), url('https://minecraft.net/static/theme/img/background/minecraft-bg.jpg'); background-size: cover; }
        .auth-box { background: rgba(40, 40, 40, 0.9); padding: 30px; border-radius: 10px; border: 2px solid #4CAF50; width: 350px; text-align: center; box-shadow: 0 0 20px rgba(0,0,0,0.5); }
        input { width: 100%; padding: 12px; margin: 10px 0; background: #333; border: 1px solid #555; color: white; border-radius: 5px; }
        button { width: 100%; padding: 12px; background: #4CAF50; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; transition: 0.3s; margin-top: 10px; }
        button:hover { background: #45a049; transform: scale(1.02); }
        .link { color: #4CAF50; cursor: pointer; text-decoration: underline; font-size: 14px; }
        .error { color: #ff5252; font-size: 13px; margin-top: 10px; }

        /* Шапка сайта */
        header { background: #252525; padding: 15px 5%; display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #4CAF50; position: sticky; top: 0; z-index: 100; }
        .logo { font-size: 22px; font-weight: bold; color: #4CAF50; text-transform: uppercase; letter-spacing: 1px; }
        nav .nav-btn { background: none; border: none; color: #ccc; margin: 0 10px; font-size: 15px; cursor: pointer; width: auto; padding: 5px 10px; }
        nav .nav-btn:hover { color: #4CAF50; }
        .admin-only { color: #ffd700 !important; font-weight: bold; }

        /* Контент */
        main { padding: 20px 5%; max-width: 1000px; margin: 0 auto; width: 100%; }
        .content-section { display: none; animation: fadeIn 0.5s; }
        .content-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        .card { background: #2d2d2d; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 5px solid #4CAF50; box-shadow: 0 4px 10px rgba(0,0,0,0.3); }
        .card img { width: 100%; border-radius: 5px; margin-bottom: 15px; max-height: 400px; object-fit: cover; }
        .badge-new { background: #ff5252; color: white; padding: 2px 8px; border-radius: 3px; font-size: 12px; margin-left: 10px; vertical-align: middle; }

        .user-tag { background: #333; padding: 5px 15px; border-radius: 20px; font-size: 14px; border: 1px solid #4CAF50; }
    </style>
</head>
<body>

    <div id="auth-screen" class="screen">
        <div class="auth-box">
            <h1 style="color:#4CAF50; margin-bottom:10px;">KAZAKH EMPIRE</h1>
            <div id="login-ui">
                <h3>Вход</h3>
                <input type="text" id="log-nick" placeholder="Ник в Minecraft">
                <input type="password" id="log-pass" placeholder="Пароль">
                <button id="btn-do-login">Войти</button>
                <p style="margin-top:15px;">Нет аккаунта? <span class="link" onclick="toggleAuth(true)">Создать</span></p>
            </div>
            <div id="reg-ui" style="display:none;">
                <h3>Регистрация</h3>
                <input type="text" id="reg-nick" placeholder="Ваш Ник">
                <input type="password" id="reg-pass" placeholder="Придумайте пароль">
                <button id="btn-do-reg">Зарегистрироваться</button>
                <p style="margin-top:15px;">Есть аккаунт? <span class="link" onclick="toggleAuth(false)">Войти</span></p>
            </div>
            <div id="auth-error" class="error"></div>
        </div>
    </div>

    <div id="main-app" class="screen" style="display:none;">
        <header>
            <div class="logo">🇰🇿 Empire</div>
            <nav>
                <button class="nav-btn" onclick="showSec('news')">Новости</button>
                <button class="nav-btn" onclick="showSec('laws')">Законы</button>
                <button class="nav-btn" onclick="alert('Скоро открытие!')">Магазин</button>
                <button class="nav-btn admin-only" id="adm-link" style="display:none;" onclick="showSec('admin')">АДМИН</button>
            </nav>
            <div style="display:flex; align-items:center; gap:10px;">
                <span class="user-tag" id="user-display">Игрок</span>
                <button onclick="logout()" style="width:auto; padding:5px 10px; background:#444; margin:0; font-size:12px;">Выход</button>
            </div>
        </header>

        <main>
            <section id="sec-news" class="content-section active">
                <h2 style="margin-bottom:20px;">Последние новости</h2>
                <div id="news-list">Загрузка новостей...</div>
            </section>

            <section id="sec-laws" class="content-section">
                <h2 style="margin-bottom:20px;">Законы Империи</h2>
                <div id="laws-list">Свод правил загружается...</div>
            </section>

            <section id="sec-admin" class="content-section">
                <h2 style="color:#ffd700;">Панель Создателя</h2>
                <div class="card">
                    <h4>Добавить новость</h4>
                    <input type="text" id="new-title" placeholder="Заголовок">
                    <input type="text" id="new-text" placeholder="Текст новости">
                    <input type="text" id="new-img" placeholder="Ссылка на фото (URL)">
                    <button onclick="addNews()">Опубликовать новость</button>
                </div>
                <div class="card">
                    <h4>Добавить закон</h4>
                    <input type="text" id="law-cat" placeholder="Раздел (например: Гриферство)">
                    <input type="text" id="law-text" placeholder="Текст правила">
                    <button onclick="addLaw()" style="background:#555;">Добавить в кодекс</button>
                </div>
            </section>
        </main>
    </div>

    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
        import { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
        import { getFirestore, collection, addDoc, query, orderBy, onSnapshot, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

        // ТВОИ КЛЮЧИ (уже вставлены)
        const firebaseConfig = {
            apiKey: "AIzaSyOsoXWRUKx-IqaYLrBhHurqj9Dn5yiPBNU",
            authDomain: "blumket-546e8.firebaseapp.com",
            databaseURL: "https://blumket-546e8-default-rtdb.europe-west1.firebasedatabase.app",
            projectId: "blumket-546e8",
            storageBucket: "blumket-546e8.firebasestorage.app",
            messagingSenderId: "333332861402",
            appId: "1:333332861402:web:2b13848d59f141c7ebb0e3"
        };

        const app = initializeApp(firebaseConfig);
        const auth = getAuth(app);
        const db = getFirestore(app);
        const suffix = "@kazakh.mc";

        // Функции переключения UI
        window.toggleAuth = (isReg) => {
            document.getElementById('login-ui').style.display = isReg ? 'none' : 'block';
            document.getElementById('reg-ui').style.display = isReg ? 'block' : 'none';
        };

        window.showSec = (id) => {
            document.querySelectorAll('.content-section').forEach(s => s.classList.remove('active'));
            document.getElementById('sec-' + id).classList.add('active');
        };

        // Регистрация
        document.getElementById('btn-do-reg').onclick = () => {
            const nick = document.getElementById('reg-nick').value;
            const pass = document.getElementById('reg-pass').value;
            if(nick.length < 3) return alert("Ник слишком короткий");
            createUserWithEmailAndPassword(auth, nick + suffix, pass)
                .catch(e => document.getElementById('auth-error').innerText = "Ошибка: " + e.message);
        };

        // Вход
        document.getElementById('btn-do-login').onclick = () => {
            const nick = document.getElementById('log-nick').value;
            const pass = document.getElementById('log-pass').value;
            signInWithEmailAndPassword(auth, nick + suffix, pass)
                .catch(e => document.getElementById('auth-error').innerText = "Неверный ник или пароль");
        };

        // Выход
        window.logout = () => signOut(auth);

        // Слежка за юзером
        onAuthStateChanged(auth, (user) => {
            if (user) {
                const nick = user.email.replace(suffix, '');
                document.getElementById('user-display').innerText = nick;
                document.getElementById('auth-screen').style.display = 'none';
                document.getElementById('main-app').style.display = 'flex';
                
                if(nick.toLowerCase() === "1mm") {
                    document.getElementById('adm-link').style.display = 'inline-block';
                }
                loadContent();
            } else {
                document.getElementById('main-app').style.display = 'none';
                document.getElementById('auth-screen').style.display = 'flex';
            }
        });

        // Админ-функции
        window.addNews = async () => {
            const title = document.getElementById('new-title').value;
            const text = document.getElementById('new-text').value;
            const img = document.getElementById('new-img').value;
            if(!title || !text) return alert("Заполни поля!");
            await addDoc(collection(db, "news"), { title, text, img, date: serverTimestamp() });
            alert("Готово!");
            document.getElementById('new-title').value = ''; document.getElementById('new-text').value = '';
        };

        window.addLaw = async () => {
            const cat = document.getElementById('law-cat').value;
            const text = document.getElementById('law-text').value;
            if(!cat || !text) return alert("Заполни поля!");
            await addDoc(collection(db, "laws"), { cat, text, date: serverTimestamp() });
            alert("Закон добавлен!");
            document.getElementById('law-text').value = '';
        };

        // Загрузка контента
        function loadContent() {
            // Новости
            onSnapshot(query(collection(db, "news"), orderBy("date", "desc")), (snap) => {
                const list = document.getElementById('news-list');
                list.innerHTML = '';
                snap.forEach(doc => {
                    const d = doc.data();
                    list.innerHTML += `<div class="card">
                        ${d.img ? `<img src="${d.img}">` : ''}
                        <h3>${d.title}</h3>
                        <p>${d.text}</p>
                    </div>`;
                });
            });

            // Законы
            onSnapshot(collection(db, "laws"), (snap) => {
                const list = document.getElementById('laws-list');
                list.innerHTML = '';
                snap.forEach(doc => {
                    const d = doc.data();
                    const isNew = d.date && (Date.now() - d.date.toMillis() < 172800000); // 2 дня
                    list.innerHTML += `<div class="card">
                        <h4>[${d.cat}] ${isNew ? '<span class="badge-new">НОВОЕ</span>' : ''}</h4>
                        <p>${d.text}</p>
                    </div>`;
                });
            });
        }
    </script>
</body>
</html>
