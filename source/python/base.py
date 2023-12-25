class ClassRegistry:
    def __init__(self):
        self.classes = {}

    def register(self, name):
        def decorator(cls):
            self.classes[name] = cls
            return cls
        return decorator

    def get_class(self, name):
        return self.classes.get(name)


# 创建一个类注册器实例
registry = ClassRegistry()