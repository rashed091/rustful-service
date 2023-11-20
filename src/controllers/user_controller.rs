use crate::services::user_service::UserService;
use salvo::prelude::*;

use crate::common::database::Database;

#[handler]
pub async fn all_users(
    req: &mut Request,
    depot: &mut Depot,
    res: &mut Response,
) {
    let mut connection = Database::new().get_connection();
    let users = UserService::list(&mut connection).await;
    res.render(Json(users));
}
