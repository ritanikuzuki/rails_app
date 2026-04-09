# Seed data for TaskPenalty
# Run: docker compose exec web bin/rails db:seed

puts "Creating seed data..."

# テストユーザーを作成（開発用）
user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.password = "password123"
  u.name = "テストユーザー"
  u.provider = "google_oauth2"
  u.uid = "test-uid-123"
end

puts "Created user: #{user.email}"

# タスクを作成
tasks_data = [
  {
    title: "プレゼン資料の作成",
    description: "来週の会議に向けてスライドを準備する。データの分析結果を含める。",
    penalty_amount: 2000,
    priority: 5,
    start_date: Date.current,
    due_date: Date.current + 5,
    milestones: ["資料の構成を決める", "データ分析", "スライド作成", "リハーサル"]
  },
  {
    title: "確定申告の書類準備",
    description: "経費の整理と必要書類の収集",
    penalty_amount: 5000,
    priority: 5,
    start_date: Date.current - 3,
    due_date: Date.current + 3,
    milestones: ["領収書の整理", "経費計算", "申告書の記入", "提出"]
  },
  {
    title: "英語の勉強 - TOEIC対策",
    description: "1日2時間のリスニングとリーディング練習",
    penalty_amount: 1000,
    priority: 3,
    start_date: Date.current,
    due_date: Date.current + 30,
    milestones: ["リスニング教材購入", "Part1-4対策", "Part5-7対策", "模擬試験"]
  },
  {
    title: "部屋の大掃除",
    description: "年度末の整理整頓",
    penalty_amount: 500,
    priority: 2,
    start_date: Date.current,
    due_date: Date.current + 7,
    milestones: ["クローゼット整理", "デスク周り", "キッチン"]
  },
  {
    title: "Webアプリのデプロイ",
    description: "本番サーバーへのデプロイとSSL設定",
    penalty_amount: 3000,
    priority: 4,
    start_date: Date.current - 1,
    due_date: Date.current + 10,
    milestones: ["サーバー設定", "DB移行", "SSL証明書", "動作確認", "ドメイン設定"]
  },
  {
    title: "読書 - 「Clean Code」",
    description: "Robert C. Martin著のクリーンコードを読破する",
    penalty_amount: 300,
    priority: 1,
    start_date: Date.current,
    due_date: Date.current + 14,
    milestones: ["Chapter 1-5", "Chapter 6-10", "Chapter 11-17"]
  },
  {
    title: "ジムの入会手続き",
    description: "近所のジムに入会して運動を習慣化する",
    penalty_amount: 1500,
    priority: 3,
    start_date: Date.current - 5,
    due_date: Date.current - 2,  # 期限切れタスク！
    milestones: ["ジムの見学", "プラン選択", "入会手続き"]
  },
  {
    title: "ポートフォリオサイトの更新",
    description: "最新のプロジェクトを追加する",
    penalty_amount: 800,
    priority: 2,
    start_date: Date.current,
    due_date: Date.current + 21,
    milestones: ["デザイン案", "コーディング", "デプロイ"]
  },
]

tasks_data.each do |data|
  milestones = data.delete(:milestones)
  task = user.tasks.create!(data)

  milestones.each_with_index do |title, index|
    task.milestones.create!(
      title: title,
      position: index + 1,
      completed: index < 1,  # 最初のマイルストーンだけ完了済み
      completed_at: index < 1 ? Time.current - 1.day : nil,
      due_date: task.due_date - (milestones.size - index).days
    )
  end

  puts "Created task: #{task.title} (#{milestones.size} milestones)"
end

puts ""
puts "=== Seed data created! ==="
puts "Login: test@example.com / password123"
puts "Tasks: #{Task.count}"
puts "Milestones: #{Milestone.count}"
