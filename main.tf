module "beanstalk_module" {
  source      = "./modules"
  DB_USERNAME = var.DB_USERNAME
  DB_PASSWORD = var.DB_PASSWORD
  DB_NAME     = var.DB_NAME
  DB_HOST = var.DB_HOST
  APP_NAME    = var.APP_NAME
  REDIS_SERVER = var.REDIS_SERVER
}