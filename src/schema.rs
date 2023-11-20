// @generated automatically by Diesel CLI.

diesel::table! {
    users (id) {
        id -> Uuid,
        name -> Text,
        age -> Int4,
    }
}
