# Application層実装ガイド

## 概要
Application層は状態管理と依存性注入を担当します。
UIとDomain層の橋渡しをします。

## ディレクトリ構成

```
3_application/
├── 1_states/      # 状態定義
├── 2_providers/   # 依存性注入プロバイダ
└── 3_notifiers/   # 状態管理ノティファイア
```

## ⚠️ 重要: Provider vs Notifier の責務分離

### Notifier (`3_notifiers/`) の責務
- UIが直接関心を持つ状態（State）の生成、更新、管理に関する**全てのロジックをここに実装します**
- `UseCase`の呼び出し、API通信などの非同期処理といった副作用を管理する責任を持ちます
- `class`に`@riverpod`アノテーションを付けることで、`Notifier`本体の実装と、UIがアクセスするための`Provider`の定義を一体化させます

### Provider (`2_providers/`) の責務
- **依存性注入Provider**: `Repository`や`UseCase`といった、アプリケーションの裏側で使われる**「部品」の依存関係を組み立てること**に特化します
- ドメイン層のインターフェースとインフラ層の実装クラスを結びつけ、インスタンスを生成する役割を担います
- このProviderに、UIの状態に関するロジックを記述することはありません

### 自動生成されるNotifier Provider
- `Notifier`に付けた`@riverpod`アノテーションによって**自動で生成されるProvider**です（例: `userNotifierProvider`）
- UIと`Notifier`の実装を切り離すための、**唯一の安全なアクセスポイント（窓口）**として機能します
- UIは常にこのProviderを介してのみ、状態を購読（`watch`）したり`Notifier`のメソッドを呼び出したりします

## 1. 状態 (`1_states/`)

### 目的
UI状態を定義

### 実装パターン
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../1_domain/1_entities/task_entity.dart';

part 'task_state.freezed.dart';

/// タスク一覧の状態
@freezed
abstract class TaskListState with _$TaskListState {
  const factory TaskListState({
    /// タスク一覧
    @Default([]) List<TaskEntity> tasks,
    /// ローディング状態
    @Default(false) bool isLoading,
    /// エラーメッセージ
    String? errorMessage,
  }) = _TaskListState;
}
```

## 2. プロバイダ (`2_providers/`)

### 目的
依存性注入

### 実装パターン
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../1_domain/2_repositories/task_repository.dart';
import '../../1_domain/3_usecases/create_task_usecase.dart';
import '../../1_domain/3_usecases/get_tasks_usecase.dart';
import '../../2_infrastructure/2_data_sources/1_local/task_local_data_source_impl.dart';
import '../../2_infrastructure/3_repositories/task_repository_impl.dart';

part 'task_providers.g.dart';

/// タスクローカルデータソースプロバイダ
@riverpod
TaskLocalDataSourceImpl taskLocalDataSource(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return TaskLocalDataSourceImpl(database);
}

/// タスクリポジトリプロバイダ
@riverpod
TaskRepository taskRepository(Ref ref) {
  final dataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(dataSource);
}

/// タスク取得ユースケースプロバイダ
@riverpod
GetTasksUseCase getTasksUseCase(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasksUseCase(repository);
}

/// タスク作成ユースケースプロバイダ
@riverpod
CreateTaskUseCase createTaskUseCase(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTaskUseCase(repository);
}
```

## 3. ノティファイア (`3_notifiers/`)

### 目的
UI状態の管理

### 実装パターン（AsyncNotifier）
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../1_domain/1_entities/task_entity.dart';
import '../2_providers/task_providers.dart';

part 'task_notifier.g.dart';

/// タスク状態管理ノティファイア
@riverpod
class TaskNotifier extends _$TaskNotifier {
  @override
  FutureOr<List<TaskEntity>> build() async {
    // 初期データの取得
    final useCase = ref.read(getTasksUseCaseProvider);
    return await useCase.execute();
  }

  /// タスクを追加
  Future<void> addTask(TaskEntity task) async {
    // ローディング状態に
    state = const AsyncValue.loading();
    
    try {
      final useCase = ref.read(createTaskUseCaseProvider);
      await useCase.execute(task);
      
      // 状態を再取得
      ref.invalidateSelf();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// タスクの完了状態をトグル
  Future<void> toggleComplete(String taskId) async {
    // 実装
  }
}
```

### ルール
- `@riverpod` アノテーションを使用
- build() で初期状態を返す
- メソッドで状態を更新
- エラーハンドリングを適切に行う
