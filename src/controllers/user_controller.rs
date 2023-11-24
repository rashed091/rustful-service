use crate::services::user_service::UserService;
use salvo::prelude::*;
use uuid::Uuid;

use crate::models::user::User;
use crate::common::database::Database;

#[handler]
pub async fn get_all_users(_req: &mut Request, _depot: &mut Depot, res: &mut Response) {
    let mut connection = Database::new().get_connection();
    let users = UserService::list(&mut connection).await;
    res.render(Json(users));
}

#[handler]
pub async fn delete_all_users(_req: &mut Request, _depot: &mut Depot, res: &mut Response) {
    let mut connection = Database::new().get_connection();
    let users = UserService::delete_all(&mut connection).await;
    res.render(Json(users));
}

#[handler]
pub async fn create_user(_req: &mut Request, _depot: &mut Depot, res: &mut Response) {
    let mut connection = Database::new().get_connection();
    let user = User {
            id: Uuid::new_v4(),
            name: "Test".to_string(),
            age: 27
        };
    let users = UserService::create(&mut connection, user).await;
    res.render(Json(users));
}

#[handler]
pub async fn get_user(req: &mut Request, _depot: &mut Depot, res: &mut Response) {
    let id = Uuid::parse_str(req.param::<&str>("id").unwrap());
    let mut connection = Database::new().get_connection();
    let users = UserService::get(&mut connection, id.unwrap()).await;
    res.render(Json(users));
}


#[handler]
pub async fn delete_user(req: &mut Request, _depot: &mut Depot, res: &mut Response) {
    let id = req.param::<Uuid>("id").unwrap();
    let mut connection = Database::new().get_connection();
    let users = UserService::delete(&mut connection, id).await;
    res.render(Json(users));
}

#[handler]
pub async fn update_user(req: &mut Request, _depot: &mut Depot, res: &mut Response) {
    let id = req.param::<Uuid>("id").unwrap();
    let mut connection = Database::new().get_connection();
    let users = UserService::update(&mut connection, id).await;
    res.render(Json(users.unwrap()));
}
