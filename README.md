# UMC PE-Mobile Study Git Workflow

UMC PE-Mobile Study 과제를 업로드하기 위한 Git 사용 방법입니다.

<br />

## 1️⃣ 폴더 구조 생성

자신의 컴퓨터에 **프로젝트를 감싸는 폴더 구조**를 생성합니다.

```
개인폴더
└ 닉네임
    └ 주차 폴더
        └ 미션 파일
```

예시

```
UMC_11th_Study
└ haechi
    └ week1
        └ mission 1
        └ mission 2
        └ mission 3
```

※ main 브랜치 병합 시 코드 충돌 방지를 위해 개인 폴더 안에서 작업합니다.

<br />

## 2️⃣ Git 저장소 생성

프로젝트 폴더에서 Git 저장소를 생성합니다.

```bash
git init
```

이 명령어를 실행하면 `.git` 폴더가 생성됩니다.

<br />

## 3️⃣ GitHub Repository 연결

GitHub 레포지토리와 로컬 프로젝트를 연결합니다.

```bash
git remote add origin 레포지토리주소
```

예시

```bash
git remote add origin https://github.com/HIUMC/UMC-11th-PE-Mobile-Study.git
```

<br />

## 4️⃣ main 브랜치 동기화

GitHub의 `main` 브랜치 변경 사항을 로컬로 가져옵니다.

```bash
git pull origin main
``` 
※ 현재 GitHub에 `README.md` 파일이 존재하기 때문에 반드시 필요합니다.

<br />

## 5️⃣ 개인 브랜치 생성

자신의 닉네임으로 브랜치를 생성합니다.

```bash
git branch 닉네임
```

예시

```bash
git branch haechi
```

<br />

## 6️⃣ 생성한 브랜치로 이동

```bash
git checkout 닉네임
```

예시

```bash
git checkout haechi
```

<br />

## 7️⃣ 코드 업로드 (Commit)

파일을 추가하고 커밋을 진행합니다.

```bash
git add .
git commit -m "커밋 메시지"
```

<br />

## 📌 커밋 컨벤션

| 타입 | 설명 |
|-----|-----|
| FEAT | 새로운 기능 추가 |
| FIX | 버그, 오류 수정 |
| CHORE | 코드 수정, 내부 파일 수정 |
| DOCS | README 등의 문서 수정 |
| REFACTOR | 코드 리팩토링 |
| TEST | 테스트 코드 추가 및 수정 |

예시

```bash
git commit -m "FEAT: 1주차 mission 1 구현"
```

---

## 8️⃣ 자신의 브랜치로 Push

⚠ **main 브랜치로 push 하면 안 됩니다**

반드시 **본인 브랜치로 push** 합니다.

```bash
git push origin 닉네임
```

예시

```bash
git push origin haechi
```

<br />

## 9️⃣ Push 확인

GitHub Repository에서 다음을 확인합니다.

- 본인의 브랜치가 생성되었는지
- 파일이 정상적으로 업로드 되었는지

<br />

## 🔟 Pull Request 생성

본인의 브랜치에 코드가 정상적으로 올라갔다면  
GitHub에서 **Compare & Pull Request** 버튼을 클릭합니다.

<br />

## 1️⃣1️⃣ Pull Request 작성 규칙

### Title

```
[닉네임/이름] n주차 미션 제출
```

예시

```
[해치/정해찬] 1주차 미션 제출
```

### Description

```
1주차 미션을 진행했습니다.
모바일 기초 개념을 공부하고 간단한 기능을 구현했습니다.
```
※ Title은 양식을 지켜주시고, description은 각자 공부한 내용이나 미션 진행 내용을 자유로운 양식으로 간단히 적어주시면 됩니다.

<br />

## 📌 주의사항

- 브랜치는 반드시 **자신의 닉네임으로 생성**
- **main 브랜치에 직접 push 금지**
- 작업은 **본인 브랜치에서 commit & push**
- 폴더 이름은 반드시 **닉네임으로 생성**

```
닉네임
└ 주차
    └ 미션 파일
```

---

