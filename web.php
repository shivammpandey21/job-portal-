<?php
/** @var Router $router */

// ---- Public ----
$router->get('/', 'HomeController@index');
$router->get('/about', 'PageController@about');
$router->get('/contact', 'PageController@contact');
$router->post('/contact', 'PageController@sendContact');
$router->get('/company/{slug}', 'PageController@company');
$router->get('/jobs', 'JobController@index');
$router->get('/jobs/{id}', 'JobController@show');

// ---- Authentication ----
$router->get('/login', 'AuthController@showLogin');
$router->post('/login', 'AuthController@login');
$router->get('/register', 'AuthController@showRegister');
$router->post('/register', 'AuthController@register');
$router->post('/logout', 'AuthController@logout');

// ---- Dashboards ----
$router->get('/dashboard', 'DashboardController@index');
$router->get('/seeker/dashboard', 'DashboardController@seeker');
$router->get('/employer/dashboard', 'DashboardController@employer');
$router->get('/admin/dashboard', 'DashboardController@admin');

// ---- Notifications ----
$router->get('/notifications', 'NotificationController@index');
$router->post('/notifications/read', 'NotificationController@readAll');

// ---- Resume download (authorised) ----
$router->get('/resumes/{id}/download', 'ResumeController@download');

// ---- Job seeker ----
$router->get('/seeker/profile', 'SeekerController@profile');
$router->post('/seeker/profile', 'SeekerController@updateProfile');
$router->post('/seeker/profile/photo/remove', 'SeekerController@removePhoto');
$router->post('/seeker/resumes', 'SeekerController@uploadResume');
$router->post('/seeker/resumes/{id}/delete', 'SeekerController@deleteResume');
$router->post('/seeker/resumes/{id}/default', 'SeekerController@defaultResume');
$router->get('/seeker/applications', 'SeekerController@applications');
$router->get('/seeker/saved', 'SeekerController@saved');
$router->post('/jobs/{id}/save', 'JobController@toggleSave');
$router->get('/jobs/{id}/apply', 'JobController@applyForm');
$router->post('/jobs/{id}/apply', 'JobController@applySubmit');

// ---- Employer ----
$router->get('/employer/company', 'EmployerController@company');
$router->post('/employer/company', 'EmployerController@updateCompany');
$router->get('/employer/jobs', 'EmployerController@jobs');
$router->get('/employer/jobs/create', 'JobController@create');
$router->post('/employer/jobs', 'JobController@store');
$router->get('/employer/jobs/{id}/edit', 'JobController@edit');
$router->post('/employer/jobs/{id}', 'JobController@update');
$router->post('/employer/jobs/{id}/close', 'JobController@close');
$router->post('/employer/jobs/{id}/delete', 'JobController@delete');
$router->get('/employer/jobs/{id}/applicants', 'EmployerController@applicants');
$router->get('/employer/applications', 'EmployerController@applicants');
$router->post('/employer/applications/{id}/status', 'EmployerController@updateStatus');

// ---- Admin ----
$router->get('/admin/users/{role}', 'AdminController@users');
$router->post('/admin/users/{id}/toggle', 'AdminController@toggleUser');
$router->post('/admin/users/{id}/delete', 'AdminController@deleteUser');
$router->get('/admin/jobs', 'AdminController@jobs');
$router->post('/admin/jobs/{id}/action', 'AdminController@jobAction');
$router->get('/admin/jobs/{id}/edit', 'AdminController@editJob');
$router->post('/admin/jobs/{id}/delete', 'AdminController@deleteJob');
$router->post('/admin/jobs/{id}', 'AdminController@updateJob');
$router->get('/admin/categories', 'AdminController@categories');
$router->post('/admin/categories', 'AdminController@saveCategory');
$router->post('/admin/categories/{id}', 'AdminController@saveCategory');
$router->post('/admin/categories/{id}/delete', 'AdminController@deleteCategory');
$router->get('/admin/applications', 'AdminController@applications');
$router->get('/admin/pages', 'AdminController@pages');
$router->post('/admin/pages/{id}', 'AdminController@savePage');
$router->get('/admin/messages', 'AdminController@messages');
$router->post('/admin/messages/{id}', 'AdminController@messageAction');
$router->get('/admin/reports', 'AdminController@reports');
