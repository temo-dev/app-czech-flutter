-- =============================================================
-- Czech for Vietnamese — Supabase Schema
-- Chạy file này trong Supabase Dashboard → SQL Editor
-- =============================================================

-- Vocabulary: từ vựng tiếng Séc-Việt
create table if not exists vocabulary (
  id                  text primary key,
  czech               text not null,
  vietnamese          text not null,
  pronunciation       text not null,
  audio_file          text,
  part_of_speech      text not null,
  tags                text[] not null default '{}',
  gender              text,
  example_czech       text,
  example_vietnamese  text
);

-- Courses: thông tin khóa học
create table if not exists courses (
  id     text primary key,
  title  text not null,
  level  text not null
);

-- Units: các chương/đơn vị học
create table if not exists units (
  id                    text primary key,
  course_id             text not null references courses(id),
  title                 text not null,
  subtitle              text not null,
  color                 text not null,
  dark_color            text not null,
  icon                  text not null,
  sort_order            int  not null default 0,
  prerequisite_unit_id  text references units(id)
);

-- Lessons: các bài học (exercises lưu dạng JSONB để giữ nguyên cấu trúc)
create table if not exists lessons (
  id          text    primary key,
  unit_id     text    not null references units(id),
  title       text    not null,
  subtitle    text,
  xp_reward   int     not null default 10,
  sort_order  int     not null default 0,
  exercises   jsonb   not null default '[]'
);

-- =============================================================
-- Row Level Security — cho phép đọc public (không cần đăng nhập)
-- =============================================================
alter table vocabulary enable row level security;
alter table courses    enable row level security;
alter table units      enable row level security;
alter table lessons    enable row level security;

create policy "Public read vocabulary" on vocabulary for select using (true);
create policy "Public read courses"    on courses    for select using (true);
create policy "Public read units"      on units      for select using (true);
create policy "Public read lessons"    on lessons    for select using (true);

-- =============================================================
-- Indexes để tăng tốc query
-- =============================================================
create index if not exists idx_units_course_id    on units(course_id);
create index if not exists idx_units_sort_order   on units(sort_order);
create index if not exists idx_lessons_unit_id    on lessons(unit_id);
create index if not exists idx_lessons_sort_order on lessons(sort_order);
