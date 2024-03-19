use diesel::{ExpressionMethods, RunQueryDsl};
use diesel::query_dsl::methods::{FilterDsl, OrderDsl};
use diesel::result::Error;

use crate::common::db::DBPooledConnection;
use crate::common::response::Response;
use crate::models::fake::{Fake, Fakes};

pub type ResponseFakes = Response<Fake>;

pub struct FakeService;

impl FakeService {
    pub fn list_fakes(conn: &mut DBPooledConnection) -> Result<ResponseFakes, Error> {
        use crate::schema::fakes::dsl::*;

        let _fakes: Vec<Fakes> = match fakes
            .filter(id.eq(id))
            .order(created_at.desc())
            .load::<Fakes>(conn)
        {
            Ok(lks) => lks,
            Err(_) => vec![],
        };

        Ok(ResponseFakes {
            results: _fakes
                .into_iter()
                .map(|l| l.to_fake())
                .collect::<Vec<Fake>>(),
        })
    }
}
