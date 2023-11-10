resource "aws_efs_file_system" "main" {
  creation_token = "lambda-transcode"
  tags = {
    Name = "lambda-transcode"
  }
}

resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
  }

  posix_user {
    gid = 0
    uid = 0
  }
}

resource "aws_efs_mount_target" "main" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.main.id
  security_groups = [data.aws_security_group.main.id]
}