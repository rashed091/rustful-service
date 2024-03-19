use std::str::FromStr;

use chrono::{DateTime, NaiveDateTime, TimeZone, Utc};
use diesel::{Insertable, Queryable};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::schema::fakes;

#[derive(Debug, Deserialize, Serialize)]
pub struct Fake {
    pub id: String,
    pub created_at: DateTime<Utc>,
}

impl Fake {
    pub fn new() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            created_at: Utc::now(),
        }
    }

    pub fn to_fake_db(&self, message: String) -> Fakes {
        Fakes {
            id: Uuid::from_str(self.id.as_str()).unwrap(),
            created_at: self.created_at.naive_utc(),
            message,
        }
    }
}

#[derive(Queryable, Insertable)]
#[diesel(table_name = fakes)]
pub struct Fakes {
    pub id: Uuid,
    pub created_at: NaiveDateTime,
    pub message: String,
}

impl Fakes {
    pub fn to_fake(&self) -> Fake {
        Fake {
            id: self.id.to_string(),
            created_at: Utc.from_utc_datetime(&self.created_at),
        }
    }
}
