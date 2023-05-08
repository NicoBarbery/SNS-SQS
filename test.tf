#crear un SNS topic
resource "aws_sns_topic" "my_topic" {
  name = "my-topic"
}

#crear una suscripción de correo electrónico en el topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "email"
  endpoint  = "barberymerida@gmail.com"
}

#crear una suscripción de SMS en el topic
resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "sms"
  endpoint  = "+59170309017"
}

#crear una SQS queue
resource "aws_sqs_queue" "my_queue" {
  name = "my-queue"
}

#Este bloque de recurso crea una política que permite que el topic SNS publique mensajes en la cola SQS.
resource "aws_sns_topic_policy" "my_topic_policy" {
  arn = aws_sns_topic.my_topic.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MyTopicPolicy",
  "Statement": [
    {
      "Sid": "MySQSPolicy",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.my_topic.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.my_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

#recurso para suscribir la cola SQS al topic SNS
resource "aws_sns_topic_subscription" "queue_subscription" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.my_queue.arn
}

resource "null_resource" "send_message" {
  provisioner "local-exec" {
    command = "aws sns publish --topic-arn ${aws_sns_topic.my_topic.arn} --subject 'Mensaje de notificación' --message 'Se ha activado el servicio.'"
  }
}