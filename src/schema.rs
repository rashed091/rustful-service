// @generated automatically by Diesel CLI.

diesel::table! {
    fakes (id) {
        id -> Uuid,
        created_at -> Timestamp,
        message -> Text,
    }
}
