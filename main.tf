module "beanstalk_module" {
  source      = "./modules"
  DB_USERNAME = var.DB_USERNAME
  DB_PASSWORD = var.DB_PASSWORD
  DB_NAME     = var.DB_NAME
  APP_NAME    = var.APP_NAME
}