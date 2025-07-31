// use axum::{
//     http::{HeaderValue, Response},
//     response::IntoResponse,
// };

// #[derive(Clone, Copy, Debug)]
// pub struct StaticCached<T, const A: usize>(pub T);

// impl<T, const A: usize> IntoResponse for StaticCached<T, A>
// where
//     T: IntoResponse,
// {
//     fn into_response(self) -> Response {
//         let mut response = self.0.into_response();
//         response.headers_mut().insert(
//             "Cache-Control",
//             HeaderValue::from_static(format!("public, max-age={}", A).as_str()),
//         );
//         response
//     }
// }

// #[derive(Clone, Copy, Debug)]
// pub struct CacheConfig<T> {
//     pub value: T,
//     pub max_age: usize,
//     pub public: bool,
//     pub must_revalidate: bool,
//     pub proxy_revalidate: bool,
//     pub no_store: bool,
//     pub no_cache: bool,
// }

// impl<T> IntoResponse for CacheConfig<T> {
//     fn into_response(self) -> Response {
//         let mut cache_control = vec![
//             if self.no_store { "no-store" } else { "" },
//             if self.no_cache { "no-cache" } else { "" },
//             if self.max_age > 0 {
//                 format!("max-age={}", self.max_age).as_str()
//             } else {
//                 ""
//             },
//             if self.must_revalidate {
//                 "must-revalidate"
//             } else {
//                 ""
//             },
//             if self.proxy_revalidate {
//                 "proxy-revalidate"
//             } else {
//                 ""
//             },
//         ];

//         cache_control.retain(|s| !s.is_empty());

//         let mut response = self.value.into_response();
//         response.headers_mut().insert(
//             "Cache-Control",
//             HeaderValue::from_static(cache_control.join(", ").as_str()),
//         );
//         response
//     }
// }
