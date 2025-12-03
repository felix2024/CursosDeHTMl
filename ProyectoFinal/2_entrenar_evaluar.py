import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.svm import SVC
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score, f1_score, confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt
import joblib # Para guardar los modelos

# --- Cargar Datos ---
print("Cargando dataset de embeddings...")
X = np.load("embeddings.npy")
y = np.load("labels.npy")

print(f"Datos cargados: {X.shape[0]} muestras.")

# --- Preprocesamiento de Etiquetas ---
# Convertir nombres ("PersonaA", "PersonaB") a números (0, 1)
le = LabelEncoder()
y_encoded = le.fit_transform(y)

# Guardamos el LabelEncoder para usarlo después en la app en vivo
joblib.dump(le, 'label_encoder.joblib')
print(f"Etiquetas codificadas. Clases encontradas: {le.classes_}")

# --- Dividir Datos (Train/Test) ---
X_train, X_test, y_train, y_test = train_test_split(
    X, y_encoded, test_size=0.25, random_state=42, stratify=y_encoded
)
print(f"Datos divididos: {len(X_train)} entrenamiento, {len(X_test)} prueba.")

# --- Función de Evaluación ---
def evaluar_modelo(modelo, nombre_modelo):
    print(f"\n--- Evaluando {nombre_modelo} ---")
    modelo.fit(X_train, y_train)
    
    # Guardar el modelo entrenado
    joblib.dump(modelo, f'modelo_{nombre_modelo.lower()}.joblib')
    print(f"Modelo guardado en 'modelo_{nombre_modelo.lower()}.joblib'")
    
    y_pred = modelo.predict(X_test)
    
    # Calcular Métricas
    accuracy = accuracy_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred, average='weighted')
    
    print(f"Accuracy: {accuracy:.4f}")
    print(f"F1-Score (weighted): {f1:.4f}")
    
    # Matriz de Confusión
    cm = confusion_matrix(y_test, y_pred)
    disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=le.classes_)
    disp.plot(cmap=plt.cm.Blues)
    plt.title(f"Matriz de Confusión - {nombre_modelo}")
    plt.show()

# --- Entrenar y Evaluar Modelos ---

# 1. Support Vector Machine (SVM)
svm_model = SVC(kernel='rbf', probability=True, C=10, random_state=42)
evaluar_modelo(svm_model, "SVM")

# 2. Multi-Layer Perceptron (MLP)
mlp_model = MLPClassifier(hidden_layer_sizes=(128, 64), max_iter=500, 
                          activation='relu', solver='adam', 
                          random_state=42, alpha=0.001)
evaluar_modelo(mlp_model, "MLP")