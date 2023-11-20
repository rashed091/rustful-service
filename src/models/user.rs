use serde::{Deserialize, Serialize};
use diesel::prelude::*;
use uuid::Uuid;

use crate::schema::users;

#[derive(Serialize, Deserialize, Queryable, Insertable)]
#[table_name = "users"]
pub struct User {
    pub id: Uuid,
    pub name: String,
    pub age: i32,
}
