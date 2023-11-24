use diesel;
use diesel::prelude::*;
use uuid::Uuid;

use crate::common::database::Connection;
use crate::models::user::User;

use crate::schema::users;
use crate::schema::users::dsl::users as all_users;

pub struct UserService;

impl UserService {
    pub async fn create(connection: &mut Connection, new_user: User) -> User {
        let _result = diesel::insert_into(users::table).values(new_user).execute(connection);

        users::table
        .order(users::id.desc())
        .first(connection)
        .unwrap()
    }

    pub async fn get(connection: &mut Connection, user_id: Uuid) -> User {
        users::table.find(user_id).select(User::as_select()).first(connection).unwrap()
    }

    pub async fn update(connection: &mut Connection, user_id: Uuid) -> QueryResult<User> {
        use crate::schema::users::dsl::{name, age};

        diesel::update(users::table.find(user_id))
        .set((name.eq("Rooh Rafan"), age.eq(30),))
        .get_result::<User>(connection)
    }

    pub async fn delete(connection: &mut Connection, user_id: Uuid) -> bool {
        diesel::delete(users::table.find(user_id)).execute(connection).is_ok()
    }

    pub async fn list(connection: &mut Connection) -> Vec<User> {
        users::table.load::<User>(connection).unwrap()
    }

    pub async fn delete_all(connection: &mut Connection) -> bool {
        diesel::delete(all_users).execute(connection).is_ok()
    }
}
