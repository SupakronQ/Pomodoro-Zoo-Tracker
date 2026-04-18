Table users {

  id uuid [primary key]

  username varchar

  coin_balance integer [default:0,note:'Cached balance.']

  current_streak integer [default:0]

  last_active_date timestamp

  created_at timestamp

}

Table transaction_types {

  id uuid [primary key]

  name varchar [note:'e.g., "pomodoro_session", "goal_completion", "ad_reward", "gacha_pull", "food_purchase"']

  display_name varchar [note:'User-friendly name like "Completed Session"']

}

Table transactions {

  id uuid [primary key]

  user_id uuid [notnull]

  transaction_type_id uuid [notnull]

  amount integer [notnull,note:"Use signed integers (e.g., -50 for a pull)."]

  balance_after integer [notnull]

  reference_id uuid [note:'ID from pomodoro_sessions, goals, gacha_items, or food tables']

  created_at timestamp [default:`now()`]

}

Table goals {

  id uuid [primary key]

  name varchar [notnull]

  category_id uuid [notnull]

  target_intervals integer [notnull]

  deadline timestamp [notnull]

  coin_earned integer [default:0]

  status varchar [notnull,note:'Managed by Dart Enum: "active", "completed", "failed", "claimed"']

  created_at timestamp [notnull]

  finished_at timestamp

}

Table categories {

  id uuid [primary key]

  user_id uuid [note:'Nullable']

  name varchar

  color_hex varchar

}

Table pomodoro_sessions {

  id uuid [primary key]

  user_id uuid

  category_id uuid

  duration_minutes integer

  coins_earned integer [default:0]

  status varchar [note:'Managed by Dart Enum: "completed", "aborted"']

  created_at timestamp

  ended_at timestamp [note:'Nullable']

}

Table rarities {

  id uuid [primary key]

  name varchar

  drop_weight integer

}

Table items {

  id uuid [primary key]

  item_type_id uuid [notnull]

  name varchar [notnull]

  description text [notnull]

  sprite_url varchar [notnull]

  created_at timestamp

}

Table animals {

  id uuid [primary key,note:'Foreign key to items.id']

  stage integer [notnull]

  next_stage_level integer

}

Table decorations {

  id uuid [primary key,note:'Foreign key to items.id']

  width_cells integer [default:1]

  height_cells integer [default:1]

}

Table backgrounds {

  id uuid [primary key,note:'Foreign key to items.id']

}

Table item_types {

  id uuid [primary key]

  name varchar [note:'e.g., "animal", "decoration", "background"']

}

Table gacha_pools {

  id uuid [primary key]

  name varchar [notnull]

}

Table gacha_items {

  id uuid [primary key]

  rarity_id uuid [notnull]

  gacha_pool_id uuid [notnull]

  item_id uuid [notnull,note:'Points to items.id']

}

Table food {

  id uuid [primary key]

  name varchar [notnull]

  description text [notnull]

  price integer [default:0]

  benefit_value integer [default:1]

  sprite_url varchar [notnull]

}

Table user_foods {

  id uuid [primary key]

  user_id uuid

  food_id uuid

  quantity integer [default:0]

}

Table user_animals {

  id uuid [primary key]

  user_id uuid [notnull]

  animal_id uuid [notnull] // Refers to animals.id (which is items.id)

  level integer [default:1]

  experience_points integer [default:0]

}

Table user_decorations {

  id uuid [primary key]

  user_id uuid [notnull]

  decoration_id uuid [notnull]

  quantity integer [default:0]

}

Table user_backgrounds {

  id uuid [primary key]

  user_id uuid [notnull]

  background_id uuid [notnull]

}

Table zoo {

  showcase_animal_id uuid [notnull]

  background_id uuid [notnull]

}

// --- Relationships ---

Ref: transactions.user_id > users.id

Ref: transactions.transaction_type_id > transaction_types.id

Ref: goals.category_id > categories.id

Ref: categories.user_id > users.id

Ref: pomodoro_sessions.user_id > users.id

Ref: pomodoro_sessions.category_id > categories.id

Ref: user_foods.user_id > users.id

Ref: user_foods.food_id > food.id

Ref: user_animals.user_id > users.id

Ref: user_animals.animal_id > animals.id

Ref: user_decorations.user_id > users.id

Ref: user_decorations.decoration_id > decorations.id

Ref: user_backgrounds.user_id > users.id

Ref: user_backgrounds.background_id > backgrounds.id

Ref: animals.id - items.id

Ref: decorations.id - items.id

Ref: backgrounds.id - items.id

Ref: items.item_type_id > item_types.id

Ref: zoo.background_id > user_backgrounds.id

Ref: zoo.showcase_animal_id > user_animals.id

Ref: gacha_items.rarity_id > rarities.id

Ref: gacha_items.gacha_pool_id > gacha_pools.id

Ref: gacha_items.item_id > items.id
