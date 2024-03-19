use salvo::prelude::*;
// use uuid::Uuid;

use crate::common::db::Database;
use crate::services::fake::FakeService;

/// list all fakes/mock data `/fakes`
#[handler]
pub async fn list(_req: &mut Request, _depot: &mut Depot, res: &mut Response) {
    // let id = req.param::<Uuid>("id").unwrap();
    let mut connection = Database::new().get_connection();
    let fakes = FakeService::list_fakes(&mut connection);
    res.render(Json(fakes.unwrap()));
}
