use diesel::r2d2::{self, ConnectionManager, PooledConnection};
use once_cell::sync::OnceCell;

pub type DbCon = diesel::PgConnection;
pub type Pool = r2d2::Pool<ConnectionManager<DbCon>>;
pub type Connection = PooledConnection<ConnectionManager<DbCon>>;

/// wrapper function for a database pool
#[derive(Clone)]
pub struct Database {
    pub pool: &'static Pool,
}

impl Default for Database {
    fn default() -> Self {
        Self::new()
    }
}

impl Database {
    pub fn new() -> Database {
        Database {
            pool: Self::get_or_init_pool(),
        }
    }

    pub fn get_connection(&self) -> Connection {
        self.pool.get().unwrap()
    }

    fn get_or_init_pool() -> &'static Pool {
        static POOL: OnceCell<Pool> = OnceCell::new();

        POOL.get_or_init(|| {
            Pool::builder()
                .connection_timeout(std::time::Duration::from_secs(5))
                .build(ConnectionManager::<DbCon>::new(Self::connection_url()))
                .unwrap()
        })
    }

    pub fn connection_url() -> String {
        std::env::var("DATABASE_URL").expect("DATABASE_URL environment variable expected.")
    }
}
