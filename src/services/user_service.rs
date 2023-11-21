use diesel;
use diesel::prelude::*;
// use uuid::Uuid;

use crate::common::database::Connection;
use crate::models::user::User;

use crate::schema::users;
// use crate::schema::users::dsl::users as all_users;

pub struct UserService;

impl UserService {
    pub async fn list(connection: &mut Connection) -> Vec<User> {
        users::table.load::<User>(connection).unwrap()
    }

    // pub async fn create(connection: &mut Connection, new_user: &User) -> User {
    //     let data = User {
    //         id: Uuid::new_v4(),
    //         name: new_user.name.clone(),
    //         age: new_user.age.clone()
    //     };

    //     let _result = diesel::insert_into(users::table).values(&data).execute(connection);

    //     users::table
    //     .order(users::id.desc())
    //     .first(connection)
    //     .unwrap()
    // }

    // pub async fn delete(connection: &mut Connection, user_id: Uuid) -> bool {
    //     diesel::delete(users::table.find(user_id)).execute(connection).is_ok()
    // }

    // pub async fn delete_all(connection: &mut Connection) -> bool {
    //     diesel::delete(all_users).execute(connection).is_ok()
    // }
}
