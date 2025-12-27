# 🚨 構造違反ログ

> このファイルは、定義されたディレクトリ構造に違反する変更を自動検知して記録します。
> AIエージェントはこのファイルを確認することで、構造の逸脱を即座に認識できます。

最終チェック: 未実行
違反件数: 0

---

## 📋 許可されたディレクトリ構造

### lib/core/ 配下
- `routing/`
- `routing/path/`
- `theme/`
- `api/`
- `database/`
- `database/table/`
- `exceptions/`

### lib/features/<feature_name>/ 配下
- `1_domain/`
- `1_domain/1_entities/`
- `1_domain/2_repositories/`
- `1_domain/3_usecases/`
- `1_domain/exceptions/`
- `2_infrastructure/`
- `2_infrastructure/1_models/`
- `2_infrastructure/2_data_sources/`
- `2_infrastructure/2_data_sources/1_local/`
- `2_infrastructure/2_data_sources/1_local/exceptions/`
- `2_infrastructure/2_data_sources/2_remote/`
- `2_infrastructure/2_data_sources/2_remote/exceptions/`
- `2_infrastructure/3_repositories/`
- `3_application/`
- `3_application/1_states/`
- `3_application/2_providers/`
- `3_application/3_notifiers/`
- `4_presentation/`
- `4_presentation/1_widgets/`
- `4_presentation/1_widgets/1_atoms/`
- `4_presentation/1_widgets/2_molecules/`
- `4_presentation/1_widgets/3_organisms/`
- `4_presentation/2_pages/`

### lib/ 直下
- `core/`
- `features/`
- `main.dart`
- `app.dart`

---

## 📝 ファイル命名規則

### Domain層 (1_domain/)

| ディレクトリ | 命名形式 | 例 |
|------------|---------|-----|
| `1_entities/` | `{name}_entity.dart` | `user_entity.dart` |
| `2_repositories/` | `{name}_repository.dart` | `user_repository.dart` |
| `3_usecases/` | `{verb}_{name}_usecase.dart` | `get_user_usecase.dart` |
| `exceptions/` | `{name}_exceptions.dart` または `{name}_exception.dart` | `user_exceptions.dart` |

### Infrastructure層 (2_infrastructure/)

| ディレクトリ | 命名形式 | 例 |
|------------|---------|-----|
| `1_models/` | `{name}_model.dart` | `user_model.dart` |
| `2_data_sources/1_local/` | `{name}_local_data_source.dart` | `user_local_data_source.dart` |
| `2_data_sources/2_remote/` | `{name}_remote_data_source.dart` | `user_remote_data_source.dart` |
| `3_repositories/` | `{name}_repository_impl.dart` | `user_repository_impl.dart` |

### Application層 (3_application/)

| ディレクトリ | 命名形式 | 例 |
|------------|---------|-----|
| `1_states/` | `{name}_state.dart` | `user_state.dart` |
| `2_providers/` | `{name}_providers.dart` | `user_providers.dart` |
| `3_notifiers/` | `{name}_notifier.dart` | `user_notifier.dart` |

### Presentation層 (4_presentation/)

| ディレクトリ | 命名形式 | 例 |
|------------|---------|-----|
| `1_widgets/1_atoms/` | `{name}_atom.dart` | `primary_button_atom.dart` |
| `1_widgets/2_molecules/` | `{name}_molecule.dart` | `user_card_molecule.dart` |
| `1_widgets/3_organisms/` | `{name}_organism.dart` | `user_list_organism.dart` |
| `2_pages/` | `{name}_page.dart` | `user_detail_page.dart` |

> 📚 詳細な命名規則は [ディレクトリ構造と命名規則](../architecture/directory_structure_and_naming_rules.md) を参照してください。


---

## 🔴 検出された違反

### 違反なし

(違反が検出されると、ここに自動的に記録されます)

---

## 📝 違反の記録フォーマット

```markdown
## [YYYY-MM-DD HH:MM:SS] 違反検出

### 違反の詳細
- **パス**: lib/違反/パス
- **違反タイプ**: 不正なディレクトリ作成
- **検出時刻**: YYYY-MM-DD HH:MM:SS

### 推奨アクション
- このディレクトリを削除
- 正しい場所に移動
- 構造計画書を確認

### 関連情報
- 作成者: (可能であれば特定)
- 関連ファイル: (あれば)
```

---

## 🔧 違反の解消方法

1. **違反を確認**
   ```bash
   cat AI/logs/structure_violations.md
   ```

2. **構造検証を実行**
   ```bash
   ./AI/scripts/bash/validate_structure.sh
   ```

3. **違反を修正**
   - 不正なディレクトリを削除または移動
   - 正しい構造に従ってファイルを配置

4. **再検証**
   ```bash
   ./AI/scripts/bash/validate_structure.sh
   ```

5. **違反ログをクリア**（すべて解消後）
   ```bash
   ./AI/scripts/bash/validate_structure.sh --clear-violations
   ```

---

## 📚 参考ドキュメント

- [Features アーキテクチャ](../architecture/lib/features/features_architecture.md)
- [Core アーキテクチャ](../architecture/lib/core/core_architecture.md)
- [構造計画書](../document/structure_plan.md)
